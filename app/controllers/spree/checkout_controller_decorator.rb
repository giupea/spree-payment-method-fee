Spree::CheckoutController.class_eval do
  # Updates the order and advances to the next state (when possible.)
  def update
    if @order.update_attributes(object_params)
      #se siamo nell'ultimo step cioe' nello state payment, allora aggiusto il totale dell'ordine col fee collegato al metodo di pagamento
      if @order.state == "payment"
        update_payment_method_fee
      end
      unless @order.next
        flash[:error] = @order.errors.full_messages.join("\n")
        redirect_to checkout_state_path(@order.state) and return
      end
        
      if @order.completed?
        session[:order_id] = nil
        flash.notice = Spree.t(:order_processed_successfully)
        flash[:commerce_tracking] = "nothing special"
        redirect_to completion_route
      else
        redirect_to checkout_state_path(@order.state)
      end
    else
      render :edit
    end
  end
  
  private
  
  def object_params
    # has_checkout_step? check is necessary due to issue described in #2910
    if @order.has_checkout_step?("payment") && @order.payment?
      if params[:payment_source].present?
        source_params = params.delete(:payment_source)[params[:order][:payments_attributes].first[:payment_method_id].underscore]

        if source_params
          params[:order][:payments_attributes].first[:source_attributes] = source_params
        end
      end

      if (params[:order][:payments_attributes])
        params[:order][:payments_attributes].first[:amount] = @order.total
      end
    end

    if params[:order]
      params[:order].permit(permitted_checkout_attributes)
    else
      {}
    end
  end
  
  def update_payment_method_fee 
    payment_attributes = object_params[:payments_attributes]
    return unless payment_attributes.present?
    destroy_fee_adjustments_for_order
      
    payment_attributes.each do |payment|
      payment_method = PaymentMethod.find(payment[:payment_method_id])
      payment_method.fees.where(currency: @order.currency).first.try do |fee|
        add_adjustment_to_order(fee)
      end
    end
  end
  
  def destroy_fee_adjustments_for_order
    fee_adjustments.destroy_all
  end

  def fee_adjustments
    @order.adjustments.where( label: Spree.t(:payment_method_check_fee_label) )
  end
    
  def add_adjustment_to_order(fee)
    @order.destroy_fee_adjustments_for_order

    adjustment = @order.adjustments.new
    adjustment.source = @order
    adjustment.amount = fee.amount
    adjustment.label = Spree.t(:payment_method_check_fee_label)
    adjustment.mandatory = true
    adjustment.eligible = true

    adjustment.save!
  end
  
end

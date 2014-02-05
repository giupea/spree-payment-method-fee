Spree::Admin::PaymentMethodsController.class_eval do
  def update
    invoke_callbacks(:update, :before)
    payment_method_type = params[:payment_method].delete(:type)
    if @payment_method['type'].to_s != payment_method_type
      if @payment_method['type'].to_s == "Spree::PaymentMethod::Check"
        @payment_method.fees.destroy_all
      end
      @payment_method.update_column(:type, payment_method_type)
      @payment_method = PaymentMethod.find(params[:id])
    end
        

    update_params = params[ActiveModel::Naming.param_key(@payment_method)] || {}
    attributes = payment_method_params.merge(update_params)
    attributes.each do |k,v|
      if k.include?("password") && attributes[k].blank?
        attributes.delete(k)
      end
    end

    if @payment_method.update_attributes(attributes)
      invoke_callbacks(:update, :after)
      flash[:success] = Spree.t(:successfully_updated, :resource => Spree.t(:payment_method))
      redirect_to edit_admin_payment_method_path(@payment_method)
    else
      invoke_callbacks(:update, :fails)
      respond_with(@payment_method)
    end
  end
  
  private
  def payment_method_params
    if params[:payment_method_check] != nil && !params[:payment_method_check].empty?
      params.require(:payment_method_check).permit(:fees_attributes => [:id, :amount, :currency, :_destroy, :payment_method_id])
    end
          
        
    params.require(:payment_method).permit(:environment, :display_on, :active, :name, :description, :fees_attributes => [:amount, :currency, :_destroy])
        
        
  end
end

package kabam.rotmg.account.web.view
{
   import com.company.assembleegameclient.account.ui.Frame;
   import com.company.assembleegameclient.account.ui.TextInputField;
   import com.company.assembleegameclient.ui.ClickableText;
   import flash.events.MouseEvent;
   import kabam.rotmg.account.web.model.AccountData;
   import org.osflash.signals.Signal;
   import org.osflash.signals.natives.NativeMappedSignal;
   
   public class WebLoginDialog extends Frame
   {
       
      
      public var cancel:Signal;
      
      public var signIn:Signal;
      
      public var forgot:Signal;
      
      public var register:Signal;
      
      private var email:TextInputField;
      
      private var password:TextInputField;
      
      private var forgotText:ClickableText;
      
      private var registerText:ClickableText;
      
      public function WebLoginDialog()
      {
         super("Sign in","Cancel","Sign in");
         this.makeUI();
         this.forgot = new NativeMappedSignal(this.forgotText,MouseEvent.CLICK);
         this.register = new NativeMappedSignal(this.registerText,MouseEvent.CLICK);
         this.cancel = new NativeMappedSignal(leftButton_,MouseEvent.CLICK);
         this.signIn = new Signal(AccountData);
      }
      
      private function makeUI() : void
      {
         this.email = new TextInputField("Email",false,"");
         addTextInputField(this.email);
         this.password = new TextInputField("Password",true,"");
         addTextInputField(this.password);
         this.forgotText = new ClickableText(12,false,"Forgot your password?  Click here");
         addNavigationText(this.forgotText);
         this.registerText = new ClickableText(12,false,"New user?  Click here to Register");
         addNavigationText(this.registerText);
         rightButton_.addEventListener(MouseEvent.CLICK,this.onSignIn);
      }
      
      private function onCancel(event:MouseEvent) : void
      {
         this.cancel.dispatch();
      }
      
      private function onSignIn(event:MouseEvent) : void
      {
         var data:AccountData = null;
         if(this.isEmailValid() && this.isPasswordValid())
         {
            data = new AccountData();
            data.username = this.email.text();
            data.password = this.password.text();
            this.signIn.dispatch(data);
         }
      }
      
      private function isPasswordValid() : Boolean
      {
         var isValid:Boolean = this.password.text() != "";
         if(!isValid)
         {
            this.password.setError("Password too short");
         }
         return isValid;
      }
      
      private function isEmailValid() : Boolean
      {
         var isValid:Boolean = this.email.text() != "";
         if(!isValid)
         {
            this.email.setError("Not a valid email address");
         }
         return isValid;
      }
      
      public function setError(error:String) : void
      {
         this.password.setError(error);
      }
   }
}

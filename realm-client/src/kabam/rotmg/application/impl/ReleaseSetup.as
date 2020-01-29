package kabam.rotmg.application.impl
{
   import com.company.assembleegameclient.parameters.Parameters;
   import kabam.rotmg.application.api.ApplicationSetup;
   
   public class ReleaseSetup implements ApplicationSetup
   {
      private const SERVER:String = "127.0.0.1";

      private const UNENCRYPTED:String = "http://" + SERVER;

      private const ENCRYPTED:String = "http://" + SERVER;
      
      private const BUILD_LABEL:String = "RotMG #{VERSION}.{MINOR}";
      
      public function ReleaseSetup()
      {
         super();
      }
      
      public function getAppEngineUrl(forceUnencrypted:Boolean = false) : String
      {
         return forceUnencrypted ? this.UNENCRYPTED : this.ENCRYPTED;
      }

      public function getBuildLabel() : String
      {
         return this.BUILD_LABEL.replace("{VERSION}",Parameters.BUILD_VERSION).replace("{MINOR}",Parameters.MINOR_VERSION);
      }
      
      public function isGameLoopMonitored() : Boolean
      {
         return false;
      }
      
      public function useProductionDialogs() : Boolean
      {
         return true;
      }
      
      public function areErrorsReported() : Boolean
      {
         return true;
      }
   }
}

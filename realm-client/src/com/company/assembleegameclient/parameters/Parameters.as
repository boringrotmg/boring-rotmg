package com.company.assembleegameclient.parameters
{
   import com.company.util.KeyCodes;
   import com.company.util.MoreDateUtil;
   import flash.display.DisplayObject;
import flash.events.Event;
import flash.net.SharedObject;
   import flash.utils.Dictionary;
   
   public class Parameters
   {
      public static const BUILD_VERSION:String = "7.0";
      public static const MINOR_VERSION:String = "0";
      public static const ENABLE_ENCRYPTION:Boolean = true;
      public static const PORT:int = 2050;
      public static const FELLOW_GUILD_COLOR:uint = 10944349;
      public static const NAME_CHOSEN_COLOR:uint = 16572160;
      public static var root:DisplayObject;
      public static const PLAYER_ROTATE_SPEED:Number = 0.003;
      public static const BREATH_THRESH:int = 20;
      public static const SERVER_CHAT_NAME:String = "";
      public static const CLIENT_CHAT_NAME:String = "*Client*";
      public static const ERROR_CHAT_NAME:String = "*Error*";
      public static const HELP_CHAT_NAME:String = "*Help*";
      public static const GUILD_CHAT_NAME:String = "*Guild*";
      public static const NAME_CHANGE_PRICE:int = 1000;
      public static const GUILD_CREATION_PRICE:int = 1000;
      
      public static var data_:Object = null;
      public static var GPURenderError:Boolean = false;
      public static var GPURenderFrame:Boolean = false;

      public static const TUTORIAL_GAMEID:int = -1;
      public static const NEXUS_GAMEID:int = -2;
      public static const NEXUSEXPLANATION_GAMEID:int = -3;
      public static const VAULT_GAMEID:int = -4;
      public static const REALM_GAMEID:int = -5;
      public static const MAPTEST_GAMEID:int = -6;
      public static const GUILDHALL_GAMEID:int = -7;

      public static const MAX_SINK_LEVEL:Number = 18;
      
      public static const TERMS_OF_USE_URL:String = "https://www.kabam.com/corporate/terms-of-service";
      public static const PRIVACY_POLICY_URL:String = "https://www.kabam.com/corporate/privacy-policy";

      public static const RANDOM1:String = "B1A5ED";
      public static const RANDOM2:String = "612a806cac78114ba5013cb531";
      public static const RSA_PUBLIC_KEY:String =
              "-----BEGIN PUBLIC KEY-----\n" +
              "MFswDQYJKoZIhvcNAQEBBQADSgAwRwJAeyjMOLhcK4o2AnFRhn8vPteUy5Fux/cX" +
              "N/J+wT/zYIEUINo02frn+Kyxx0RIXJ3CvaHkwmueVL8ytfqo8Ol/OwIDAQAB\n" +
              "-----END PUBLIC KEY-----";

      private static var savedOptions_:SharedObject = null;
      private static var keyNames_:Dictionary = new Dictionary();

      public function Parameters()
      {
         super();
      }
      
      public static function load() : void
      {
         try
         {
            savedOptions_ = SharedObject.getLocal("OSGameClientOptions","/");
            data_ = savedOptions_.data;
         }
         catch(error:Error)
         {
            trace("WARNING: unable to save settings");
            data_ = new Object();
         }
         setDefaults();
         save();
      }
      
      public static function save() : void
      {
         try
         {
            if(savedOptions_ != null)
            {
               savedOptions_.flush();
            }
         }
         catch(error:Error)
         {
         }
      }
      
      private static function setDefaultKey(keyName:String, key:uint) : void
      {
         if(!data_.hasOwnProperty(keyName))
         {
            data_[keyName] = key;
         }
         keyNames_[keyName] = true;
      }
      
      public static function setKey(keyName:String, key:uint) : void
      {
         var otherKeyName:* = null;
         for(otherKeyName in keyNames_)
         {
            if(data_[otherKeyName] == key)
            {
               data_[otherKeyName] = KeyCodes.UNSET;
            }
         }
         data_[keyName] = key;
      }
      
      private static function setDefault(keyName:String, value:*) : void
      {
         if(!data_.hasOwnProperty(keyName))
         {
            data_[keyName] = value;
         }
      }

      public static function isGpuRender():Boolean {
         return !GPURenderError && data_.GPURender;
      }

      public static function clearGpuRenderEvent(event:Event):void {
         clearGpuRender();
      }

      public static function clearGpuRender():void {
         GPURenderError = true;
      }
      
      public static function setDefaults() : void
      {
         setDefaultKey("moveLeft",KeyCodes.A);
         setDefaultKey("moveRight",KeyCodes.D);
         setDefaultKey("moveUp",KeyCodes.W);
         setDefaultKey("moveDown",KeyCodes.S);
         setDefaultKey("rotateLeft",KeyCodes.Q);
         setDefaultKey("rotateRight",KeyCodes.E);
         setDefaultKey("useSpecial",KeyCodes.SPACE);
         setDefaultKey("interact",KeyCodes.NUMBER_0);
         setDefaultKey("useInvSlot1",KeyCodes.NUMBER_1);
         setDefaultKey("useInvSlot2",KeyCodes.NUMBER_2);
         setDefaultKey("useInvSlot3",KeyCodes.NUMBER_3);
         setDefaultKey("useInvSlot4",KeyCodes.NUMBER_4);
         setDefaultKey("useInvSlot5",KeyCodes.NUMBER_5);
         setDefaultKey("useInvSlot6",KeyCodes.NUMBER_6);
         setDefaultKey("useInvSlot7",KeyCodes.NUMBER_7);
         setDefaultKey("useInvSlot8",KeyCodes.NUMBER_8);
         setDefaultKey("escapeToNexus",KeyCodes.INSERT);
         setDefaultKey("escapeToNexus2",KeyCodes.F5);
         setDefaultKey("autofireToggle",KeyCodes.I);
         setDefaultKey("scrollChatUp",KeyCodes.PAGE_UP);
         setDefaultKey("scrollChatDown",KeyCodes.PAGE_DOWN);
         setDefaultKey("miniMapZoomOut",KeyCodes.MINUS);
         setDefaultKey("miniMapZoomIn",KeyCodes.EQUAL);
         setDefaultKey("resetToDefaultCameraAngle",KeyCodes.R);
         setDefaultKey("togglePerformanceStats",KeyCodes.UNSET);
         setDefaultKey("options",KeyCodes.O);
         setDefaultKey("toggleCentering",KeyCodes.UNSET);
         setDefaultKey("chat",KeyCodes.ENTER);
         setDefaultKey("chatCommand",KeyCodes.SLASH);
         setDefaultKey("tell",KeyCodes.TAB);
         setDefaultKey("guildChat",KeyCodes.G);
         setDefaultKey("testOne",KeyCodes.J);
         setDefaultKey("testTwo",KeyCodes.K);
         setDefaultKey("useHealthPotion",KeyCodes.F);
         setDefaultKey("useMagicPotion",KeyCodes.V);
         setDefaultKey("switchTabs", KeyCodes.B);
         setDefault("playerObjectType",782);
         setDefault("playMusic",true);
         setDefault("playSFX",true);
         setDefault("playPewPew",true);
         setDefault("centerOnPlayer",true);
         setDefault("preferredServer",null);
         setDefault("cameraAngle",7 * Math.PI / 4);
         setDefault("defaultCameraAngle",7 * Math.PI / 4);
         setDefault("showQuestPortraits",true);
         setDefault("allowRotation",false);
         setDefault("charIdUseMap",{});
         setDefault("drawShadows",true);
         setDefault("textBubbles",true);
         setDefault("showTradePopup",true);
         setDefault("paymentMethod",null);
         setDefault("showGuildInvitePopup",true);
         setDefault("contextualClick",true);
         setDefault("inventorySwap",true);
         setDefault("GPURender", false);
         setDefault("eyeCandyParticles", true);
         setDefault("hpBars", true);
         setDefault("allyShots", true);
         setDefault("allyDamage", true);
         setDefault("allyNotifs", true);
      }
   }
}

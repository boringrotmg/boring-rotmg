package com.company.assembleegameclient.sound
{
   import com.company.assembleegameclient.parameters.Parameters;
   import flash.media.Sound;
   import flash.media.SoundChannel;
   import flash.media.SoundTransform;
   import flash.net.URLRequest;
   import kabam.rotmg.application.api.ApplicationSetup;
   import kabam.rotmg.core.StaticInjectorContext;
   
   public class Music
   {
      
      private static var music_:Sound = null;
      
      private static var musicChannel_:SoundChannel = null;
       
      
      public function Music()
      {
         super();
      }
      
      public static function load() : void
      {
         var setup:ApplicationSetup = StaticInjectorContext.getInjector().getInstance(ApplicationSetup);
         var url:String = setup.getAppEngineUrl(true) + "/music/sorc.mp3";
         music_ = new Sound();
         music_.load(new URLRequest(url));
         musicChannel_ = music_.play(0,int.MAX_VALUE,new SoundTransform(Boolean(Parameters.data_.playMusic)?Number(0.3):Number(0)));
      }
      
      public static function setPlayMusic(playMusic:Boolean) : void
      {
         Parameters.data_.playMusic = playMusic;
         Parameters.save();
         if (!playMusic && musicChannel_ != null)
         {
            musicChannel_.stop();
            musicChannel_ = null;
         }
         else
         {
            musicChannel_ = music_.play(0,int.MAX_VALUE, new SoundTransform(Boolean(Parameters.data_.playMusic)?Number(0.3):Number(0)));
         }
      }
   }
}

package com.company.assembleegameclient.ui.tooltip
{
   public class TooltipHelper
   {
      
      public static const BETTER_COLOR:String = "#00ff00";
      
      public static const WORSE_COLOR:String = "#ff0000";
      
      public static const NO_DIFF_COLOR:String = "#FFFF8F";
       
      
      public function TooltipHelper()
      {
         super();
      }
      
      public static function wrapInFontTag(text:String, color:String) : String
      {
         var tagStr:String = "<font color=\"" + color + "\">" + text + "</font>";
         return tagStr;
      }
      
      public static function getFormattedRangeString(range:Number) : String
      {
         var decimalPart:Number = range - int(range);
         return int(decimalPart * 10) == 0?int(range).toString():range.toFixed(1);
      }
      
      public static function getTextColor(difference:Number) : String
      {
         if(difference < 0)
         {
            return WORSE_COLOR;
         }
         if(difference > 0)
         {
            return BETTER_COLOR;
         }
         return NO_DIFF_COLOR;
      }
   }
}

package com.company.assembleegameclient.ui.tooltip
{
   import com.company.assembleegameclient.constants.InventoryOwnerTypes;
   import com.company.assembleegameclient.objects.ObjectLibrary;
   import com.company.assembleegameclient.objects.Player;
   import com.company.assembleegameclient.parameters.Parameters;
   import com.company.assembleegameclient.ui.LineBreakDesign;
   import com.company.ui.SimpleText;
   import com.company.util.BitmapUtil;
   import com.company.util.KeyCodes;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.filters.DropShadowFilter;
   import flash.text.StyleSheet;
   import kabam.rotmg.constants.ActivationType;
   import kabam.rotmg.messaging.impl.data.StatData;
   
   public class EquipmentToolTip extends ToolTip
   {
      private static const MAX_WIDTH:int = 230;
      private static const CSS_TEXT:String = ".in { margin-left:10px; text-indent: -10px; }";
      
      private var icon_:Bitmap;
      private var titleText_:SimpleText;
      private var tierText_:SimpleText;
      private var descText_:SimpleText;
      private var line1_:LineBreakDesign;
      private var effectsText_:SimpleText;
      private var line2_:LineBreakDesign;
      private var restrictionsText_:SimpleText;
      private var player_:Player;
      private var isEquippable_:Boolean = false;
      private var objectType_:int;
      private var curItemXML_:XML = null;
      private var objectXML_:XML = null;
      private var slotTypeToTextBuilder:SlotComparisonFactory;
      private var playerCanUse:Boolean;
      private var restrictions:Vector.<Restriction>;
      private var effects:Vector.<Effect>;
      private var itemSlotTypeId:int;
      private var invType:int;
      private var inventoryOwnerType:String;
      private var inventorySlotID:uint;
      private var isInventoryFull:Boolean;
      private var yOffset:int;
      private var comparisonResults:SlotComparisonResult;
      
      public function EquipmentToolTip(objectType:int, player:Player, invType:int, inventoryOwnerType:String, inventorySlotID:uint = 1.0)
      {
         this.player_ = player;
         this.inventoryOwnerType = inventoryOwnerType;
         this.inventorySlotID = inventorySlotID;
         this.isInventoryFull = Boolean(player)?Boolean(player.isInventoryFull()):Boolean(false);
         this.playerCanUse = player != null?Boolean(ObjectLibrary.isUsableByPlayer(objectType,player)):Boolean(false);
         var backgroundColor:uint = this.playerCanUse || this.player_ == null ? 0x363636 : 6036765;
         var outlineColor:uint = this.playerCanUse || player == null ? 0x9B9B9B : 10965039;
         super(backgroundColor,1,outlineColor,1,true);
         this.slotTypeToTextBuilder = new SlotComparisonFactory();
         this.objectType_ = objectType;
         this.objectXML_ = ObjectLibrary.xmlLibrary_[objectType];
         var equipSlotIndex:int = Boolean(this.player_)?int(ObjectLibrary.getMatchingSlotIndex(this.objectType_,this.player_)):int(-1);
         this.isEquippable_ = equipSlotIndex != -1;
         this.effects = new Vector.<Effect>();
         this.invType = invType;
         this.itemSlotTypeId = int(this.objectXML_.SlotType);
         if(this.player_ == null)
         {
            this.curItemXML_ = this.objectXML_;
         }
         else if(this.isEquippable_)
         {
            if(this.player_.equipment_[equipSlotIndex] != -1)
            {
               this.curItemXML_ = ObjectLibrary.xmlLibrary_[this.player_.equipment_[equipSlotIndex]];
            }
         }
         this.addIcon();
         this.addTitle();
         this.addTierText();
         this.addDescriptionText();
         this.buildCategorySpecificText();
         this.addNumProjectilesTagsToEffectsList();
         this.addProjectileTagsToEffectsList();
         this.addActivateTagsToEffectsList();
         this.addActivateOnEquipTagsToEffectsList();
         this.addDoseTagsToEffectsList();
         this.addMpCostTagToEffectsList();
         this.addFameBonusTagToEffectsList();
         this.makeEffectsList();
         this.makeRestrictionList();
         this.makeRestrictionText();
      }
      
      private static function BuildRestrictionsHTML(restrictions:Vector.<Restriction>) : String
      {
         var restriction:Restriction = null;
         var line:String = null;
         var html:String = "";
         var first:Boolean = true;
         for each(restriction in restrictions)
         {
            if(!first)
            {
               html = html + "\n";
            }
            else
            {
               first = false;
            }
            line = "<font color=\"#" + restriction.color_.toString(16) + "\">" + restriction.text_ + "</font>";
            if(restriction.bold_)
            {
               line = "<b>" + line + "</b>";
            }
            html = html + line;
         }
         return html;
      }
      
      private function isEmptyEquipSlot() : Boolean
      {
         return this.isEquippable_ && this.curItemXML_ == null;
      }
      
      private function addIcon() : void
      {
         var eqXML:XML = ObjectLibrary.xmlLibrary_[this.objectType_];
         var scaleValue:int = 5;
         if(eqXML.hasOwnProperty("ScaleValue"))
         {
            scaleValue = eqXML.ScaleValue;
         }
         var texture:BitmapData = ObjectLibrary.getRedrawnTextureFromType(this.objectType_,60,true,true,scaleValue);
         texture = BitmapUtil.cropToBitmapData(texture,4,4,texture.width - 8,texture.height - 8);
         this.icon_ = new Bitmap(texture);
         addChild(this.icon_);
      }
      
      private function addTierText() : void
      {
         this.tierText_ = new SimpleText(16,16777215,false,30,0);
         this.titleText_.setBold(true);
         this.tierText_.y = this.icon_.height / 2 - this.titleText_.actualHeight_ / 2;
         this.tierText_.x = MAX_WIDTH - 30;
         if(this.objectXML_.hasOwnProperty("Consumable") == false && this.isPet() == false)
         {
            if(this.objectXML_.hasOwnProperty("Tier"))
            {
               this.tierText_.text = "T" + this.objectXML_.Tier;
            }
            else
            {
               this.tierText_.setColor(9055202);
               this.tierText_.text = "UT";
            }
            this.tierText_.updateMetrics();
            addChild(this.tierText_);
         }
      }
      
      private function isPet() : Boolean
      {
         var activateTags:XMLList = null;
         activateTags = this.objectXML_.Activate.(text() == "PermaPet");
         return activateTags.length() >= 1;
      }
      
      private function addTitle() : void
      {
         var color:int = this.playerCanUse || this.player_ == null?int(16777215):int(16549442);
         this.titleText_ = new SimpleText(16,color,false,MAX_WIDTH - this.icon_.width - 4 - 30,0);
         this.titleText_.setBold(true);
         this.titleText_.wordWrap = true;
         this.titleText_.text = ObjectLibrary.typeToDisplayId_[this.objectType_];
         this.titleText_.updateMetrics();
         this.titleText_.filters = [new DropShadowFilter(0,0,0,0.5,12,12)];
         this.titleText_.x = this.icon_.width + 4;
         this.titleText_.y = this.icon_.height / 2 - this.titleText_.actualHeight_ / 2;
         addChild(this.titleText_);
      }
      
      private function buildUniqueTooltipData() : String
      {
         var effectDataList:XMLList = null;
         var uniqueEffectList:Vector.<Effect> = null;
         var effectDataXML:XML = null;
         if(this.objectXML_.hasOwnProperty("ExtraTooltipData"))
         {
            effectDataList = this.objectXML_.ExtraTooltipData.EffectInfo;
            uniqueEffectList = new Vector.<Effect>();
            for each(effectDataXML in effectDataList)
            {
               uniqueEffectList.push(new Effect(effectDataXML.attribute("name"),effectDataXML.attribute("description")));
            }
            return this.BuildEffectsHTML(uniqueEffectList) + "\n";
         }
         return "";
      }
      
      private function makeEffectsList() : void
      {
         this.yOffset = this.descText_.y + this.descText_.height + 8;
         if(this.effects.length != 0 || this.comparisonResults.text != "" || this.objectXML_.hasOwnProperty("ExtraTooltipData"))
         {
            this.line1_ = new LineBreakDesign(MAX_WIDTH - 12,0);
            this.line1_.x = 8;
            this.line1_.y = this.yOffset;
            addChild(this.line1_);
            this.effectsText_ = new SimpleText(14,11776947,false,MAX_WIDTH - this.icon_.width - 4,0);
            this.effectsText_.wordWrap = true;
            this.effectsText_.htmlText = this.buildUniqueTooltipData() + this.comparisonResults.text + this.BuildEffectsHTML(this.effects);
            this.effectsText_.useTextDimensions();
            this.effectsText_.filters = [new DropShadowFilter(0,0,0,0.5,12,12)];
            this.effectsText_.x = 4;
            this.effectsText_.y = this.line1_.y + 8;
            addChild(this.effectsText_);
            this.yOffset = this.effectsText_.y + this.effectsText_.height + 8;
         }
      }
      
      private function addNumProjectilesTagsToEffectsList() : void
      {
         if(this.objectXML_.hasOwnProperty("NumProjectiles") && this.comparisonResults.processedTags.hasOwnProperty(this.objectXML_.NumProjectiles.toXMLString()) != true)
         {
            this.effects.push(new Effect("Shots",this.objectXML_.NumProjectiles));
         }
      }
      
      private function addFameBonusTagToEffectsList() : void
      {
         var fameBonus:int = 0;
         var text:String = null;
         var textColor:String = null;
         var curFameBonus:int = 0;
         if(this.objectXML_.hasOwnProperty("FameBonus"))
         {
            fameBonus = int(this.objectXML_.FameBonus);
            text = fameBonus + "%";
            textColor = this.playerCanUse?TooltipHelper.BETTER_COLOR:TooltipHelper.NO_DIFF_COLOR;
            if(this.curItemXML_ != null && this.curItemXML_.hasOwnProperty("FameBonus"))
            {
               curFameBonus = int(this.curItemXML_.FameBonus.text());
               textColor = TooltipHelper.getTextColor(fameBonus - curFameBonus);
            }
            this.effects.push(new Effect("Fame Bonus",TooltipHelper.wrapInFontTag(text,textColor)));
         }
      }
      
      private function addMpCostTagToEffectsList() : void
      {
         if(this.objectXML_.hasOwnProperty("MpEndCost"))
         {
            if(!this.comparisonResults.processedTags[this.objectXML_.MpEndCost[0].toXMLString()])
            {
               this.effects.push(new Effect("MP Cost",this.objectXML_.MpEndCost));
            }
         }
         else if(this.objectXML_.hasOwnProperty("MpCost") && !this.comparisonResults.processedTags[this.objectXML_.MpCost[0].toXMLString()])
         {
            if(!this.comparisonResults.processedTags[this.objectXML_.MpCost[0].toXMLString()])
            {
               this.effects.push(new Effect("MP Cost",this.objectXML_.MpCost));
            }
         }
      }
      
      private function addDoseTagsToEffectsList() : void
      {
         if(this.objectXML_.hasOwnProperty("Doses"))
         {
            this.effects.push(new Effect("Doses",this.objectXML_.Doses));
         }
      }
      
      private function addProjectileTagsToEffectsList() : void
      {
         var projXML:XML = null;
         var minD:int = 0;
         var maxD:int = 0;
         var range:Number = NaN;
         var condEffectXML:XML = null;
         if(this.objectXML_.hasOwnProperty("Projectile") && this.comparisonResults.processedTags.hasOwnProperty(this.objectXML_.Projectile.toXMLString()) == false)
         {
            projXML = XML(this.objectXML_.Projectile);
            minD = int(projXML.MinDamage);
            maxD = int(projXML.MaxDamage);
            this.effects.push(new Effect("Damage",(minD == maxD?minD:minD + " - " + maxD).toString()));
            range = Number(projXML.Speed) * Number(projXML.LifetimeMS) / 10000;
            this.effects.push(new Effect("Range",TooltipHelper.getFormattedRangeString(range)));
            if(this.objectXML_.Projectile.hasOwnProperty("MultiHit"))
            {
               this.effects.push(new Effect("","Shots hit multiple targets"));
            }
            if(this.objectXML_.Projectile.hasOwnProperty("PassesCover"))
            {
               this.effects.push(new Effect("","Shots pass through obstacles"));
            }
            for each(condEffectXML in projXML.ConditionEffect)
            {
               if(this.comparisonResults.processedTags[condEffectXML.toXMLString()] == null)
               {
                  this.effects.push(new Effect("Shot Effect",this.objectXML_.Projectile.ConditionEffect + " for " + this.objectXML_.Projectile.ConditionEffect.@duration + " secs"));
               }
            }
         }
      }
      
      private function addActivateTagsToEffectsList() : void
      {
         var activateXML:XML = null;
         var val:String = null;
         var stat:int = 0;
         var amt:int = 0;
         var activationType:String = null;
         for each(activateXML in this.objectXML_.Activate)
         {
            if(this.comparisonResults.processedTags[activateXML.toXMLString()] == true)
            {
               continue;
            }
            activationType = activateXML.toString();
            switch(activationType)
            {
               case ActivationType.COND_EFFECT_AURA:
                  this.effects.push(new Effect("Party Effect","Within " + activateXML.@range + " sqrs"));
                  this.effects.push(new Effect("","  " + activateXML.@effect + " for " + activateXML.@duration + " secs"));
                  continue;
               case ActivationType.COND_EFFECT_SELF:
                  this.effects.push(new Effect("Effect on Self",""));
                  this.effects.push(new Effect("","  " + activateXML.@effect + " for " + activateXML.@duration + " secs"));
                  continue;
               case ActivationType.HEAL:
                  this.effects.push(new Effect("","+" + activateXML.@amount + " HP"));
                  continue;
               case ActivationType.HEAL_NOVA:
                  this.effects.push(new Effect("Party Heal",activateXML.@amount + " HP at " + activateXML.@range + " sqrs"));
                  continue;
               case ActivationType.MAGIC:
                  this.effects.push(new Effect("","+" + activateXML.@amount + " MP"));
                  continue;
               case ActivationType.MAGIC_NOVA:
                  this.effects.push(new Effect("Fill Party Magic",activateXML.@amount + " MP at " + activateXML.@range + " sqrs"));
                  continue;
               case ActivationType.TELEPORT:
                  this.effects.push(new Effect("","Teleport to Target"));
                  continue;
               case ActivationType.VAMPIRE_BLAST:
                  this.effects.push(new Effect("Steal",activateXML.@totalDamage + " HP within " + activateXML.@radius + " sqrs"));
                  continue;
               case ActivationType.TRAP:
                  this.effects.push(new Effect("Trap",activateXML.@totalDamage + " HP within " + activateXML.@radius + " sqrs"));
                  this.effects.push(new Effect("","  " + (Boolean(activateXML.hasOwnProperty("@condEffect"))?activateXML.@condEffect:"Slowed") + " for " + (Boolean(activateXML.hasOwnProperty("@condDuration"))?activateXML.@condDuration:"5") + " secs"));
                  continue;
               case ActivationType.STASIS_BLAST:
                  this.effects.push(new Effect("Stasis on Group",activateXML.@duration + " secs"));
                  continue;
               case ActivationType.DECOY:
                  this.effects.push(new Effect("Decoy",activateXML.@duration + " secs"));
                  continue;
               case ActivationType.LIGHTNING:
                  this.effects.push(new Effect("Lightning",""));
                  this.effects.push(new Effect(""," " + activateXML.@totalDamage + " to " + activateXML.@maxTargets + " targets"));
                  continue;
               case ActivationType.POISON_GRENADE:
                  this.effects.push(new Effect("Poison Grenade",""));
                  this.effects.push(new Effect(""," " + activateXML.@totalDamage + " HP over " + activateXML.@duration + " secs within " + activateXML.@radius + " sqrs\n"));
                  continue;
               case ActivationType.REMOVE_NEG_COND:
                  this.effects.push(new Effect("","Removes negative conditions"));
                  continue;
               case ActivationType.REMOVE_NEG_COND_SELF:
                  this.effects.push(new Effect("","Removes negative conditions"));
                  continue;
               case ActivationType.INCREMENT_STAT:
                  stat = int(activateXML.@stat);
                  amt = int(activateXML.@amount);
                  if(stat != StatData.HP_STAT && stat != StatData.MP_STAT)
                  {
                     val = "Permanently increases " + StatData.statToName(stat);
                  }
                  else
                  {
                     val = "+" + amt + " " + StatData.statToName(stat);
                  }
                  this.effects.push(new Effect("",val));
                  continue;
               default:

            }
         }
      }
      
      private function formatStringForPluralValue(amount:uint, string:String) : String
      {
         if(amount > 1)
         {
            string = string + "s";
         }
         return string;
      }
      
      private function addActivateOnEquipTagsToEffectsList() : void
      {
         var activateXML:XML = null;
         var customText:String = null;
         var first:Boolean = true;
         for each(activateXML in this.objectXML_.ActivateOnEquip)
         {
            if(first)
            {
               this.effects.push(new Effect("On Equip",""));
               first = false;
            }
            customText = this.comparisonResults.processedActivateOnEquipTags[activateXML.toXMLString()];
            if(customText != null)
            {
               this.effects.push(new Effect(""," " + customText));
            }
            else if(activateXML.toString() == "IncrementStat")
            {
               this.effects.push(new Effect("",this.compareIncrementStat(activateXML)));
            }
         }
      }
      
      private function compareIncrementStat(activateXML:XML) : String
      {
         var amountString:String = null;
         var match:XML = null;
         var otherAmount:int = 0;
         var stat:int = int(activateXML.@stat);
         var amount:int = int(activateXML.@amount);
         var textColor:String = this.playerCanUse?TooltipHelper.BETTER_COLOR:TooltipHelper.NO_DIFF_COLOR;
         var otherMatches:XMLList = null;
         if(this.curItemXML_ != null)
         {
            otherMatches = this.curItemXML_.ActivateOnEquip.(@stat == stat);
         }
         if(otherMatches != null && otherMatches.length() == 1)
         {
            match = XML(otherMatches[0]);
            otherAmount = int(match.@amount);
            textColor = TooltipHelper.getTextColor(amount - otherAmount);
         }
         if(amount > -1)
         {
            amountString = String("+" + amount);
         }
         else
         {
            amountString = String(amount);
            textColor = "#FF0000";
         }
         return TooltipHelper.wrapInFontTag(amountString + " " + StatData.statToName(stat),textColor);
      }
      
      private function addEquipmentItemRestrictions() : void
      {
         this.restrictions.push(new Restriction("Must be equipped to use",11776947,false));
         if(this.isInventoryFull || this.inventoryOwnerType == InventoryOwnerTypes.CURRENT_PLAYER)
         {
            this.restrictions.push(new Restriction("Double-Click to equip",11776947,false));
         }
         else
         {
            this.restrictions.push(new Restriction("Double-Click to take",11776947,false));
         }
      }
      
      private function addAbilityItemRestrictions() : void
      {
         this.restrictions.push(new Restriction("Press [" + KeyCodes.CharCodeStrings[Parameters.data_.useSpecial] + "] in world to use",16777215,false));
      }
      
      private function addConsumableItemRestrictions() : void
      {
         this.restrictions.push(new Restriction("Consumed with use",11776947,false));
         if(this.isInventoryFull || this.inventoryOwnerType == InventoryOwnerTypes.CURRENT_PLAYER)
         {
            this.restrictions.push(new Restriction("Double-Click or Shift-Click on item to use",16777215,false));
         }
         else
         {
            this.restrictions.push(new Restriction("Double-Click to take & Shift-Click to use",16777215,false));
         }
      }
      
      private function addReusableItemRestrictions() : void
      {
         this.restrictions.push(new Restriction("Can be used multiple times",11776947,false));
         this.restrictions.push(new Restriction("Double-Click or Shift-Click on item to use",16777215,false));
      }
      
      private function makeRestrictionList() : void
      {
         var reqXML:XML = null;
         var reqMet:Boolean = false;
         var stat:int = 0;
         var value:int = 0;
         this.restrictions = new Vector.<Restriction>();
         if(this.objectXML_.hasOwnProperty("VaultItem") && this.invType != -1 && this.invType != ObjectLibrary.idToType_["Vault Chest"])
         {
            this.restrictions.push(new Restriction("Store this item in your Vault to avoid losing it!",16549442,true));
         }
         if(this.objectXML_.hasOwnProperty("Soulbound"))
         {
            this.restrictions.push(new Restriction("Soulbound",11776947,false));
         }
         if(this.playerCanUse)
         {
            if(this.objectXML_.hasOwnProperty("Usable"))
            {
               this.addAbilityItemRestrictions();
               this.addEquipmentItemRestrictions();
            }
            else if(this.objectXML_.hasOwnProperty("Consumable"))
            {
               this.addConsumableItemRestrictions();
            }
            else if(this.objectXML_.hasOwnProperty("InvUse"))
            {
               this.addReusableItemRestrictions();
            }
            else
            {
               this.addEquipmentItemRestrictions();
            }
         }
         else if(this.player_ != null)
         {
            this.restrictions.push(new Restriction("Not usable by " + ObjectLibrary.typeToDisplayId_[this.player_.objectType_],16549442,true));
         }
         var usable:Vector.<String> = ObjectLibrary.usableBy(this.objectType_);
         if(usable != null)
         {
            this.restrictions.push(new Restriction("Usable by: " + usable.join(", "),11776947,false));
         }
         for each(reqXML in this.objectXML_.EquipRequirement)
         {
            reqMet = ObjectLibrary.playerMeetsRequirement(reqXML,this.player_);
            if(reqXML.toString() == "Stat")
            {
               stat = int(reqXML.@stat);
               value = int(reqXML.@value);
               this.restrictions.push(new Restriction("Requires " + StatData.statToName(stat) + " of " + value,reqMet?11776947:16549442,reqMet?Boolean(false):Boolean(true)));
            }
         }
      }
      
      private function makeRestrictionText() : void
      {
         var sheet:StyleSheet = null;
         if(this.restrictions.length != 0)
         {
            this.line2_ = new LineBreakDesign(MAX_WIDTH - 12,0);
            this.line2_.x = 8;
            this.line2_.y = this.yOffset;
            addChild(this.line2_);
            sheet = new StyleSheet();
            sheet.parseCSS(CSS_TEXT);
            this.restrictionsText_ = new SimpleText(14,11776947,false,MAX_WIDTH - 4,0);
            this.restrictionsText_.styleSheet = sheet;
            this.restrictionsText_.wordWrap = true;
            this.restrictionsText_.htmlText = "<span class=\'in\'>" + BuildRestrictionsHTML(this.restrictions) + "</span>";
            this.restrictionsText_.useTextDimensions();
            this.restrictionsText_.filters = [new DropShadowFilter(0,0,0,0.5,12,12)];
            this.restrictionsText_.x = 4;
            this.restrictionsText_.y = this.line2_.y + 8;
            addChild(this.restrictionsText_);
         }
      }
      
      private function addDescriptionText() : void
      {
         this.descText_ = new SimpleText(14,11776947,false,MAX_WIDTH,0);
         this.descText_.wordWrap = true;
         this.descText_.text = String(this.objectXML_.Description);
         this.descText_.updateMetrics();
         this.descText_.filters = [new DropShadowFilter(0,0,0,0.5,12,12)];
         this.descText_.x = 4;
         this.descText_.y = this.icon_.height + 2;
         addChild(this.descText_);
      }
      
      private function buildCategorySpecificText() : void
      {
         if(this.curItemXML_ != null)
         {
            this.comparisonResults = this.slotTypeToTextBuilder.getComparisonResults(this.objectXML_,this.curItemXML_);
         }
         else
         {
            this.comparisonResults = new SlotComparisonResult();
         }
      }
      
      private function BuildEffectsHTML(effects:Vector.<Effect>) : String
      {
         var effect:Effect = null;
         var textColor:String = null;
         var html:String = "";
         var first:Boolean = true;
         for each(effect in effects)
         {
            textColor = "#FFFF8F";
            if(!first)
            {
               html = html + "\n";
            }
            else
            {
               first = false;
            }
            if(effect.name_ != "")
            {
               html = html + (effect.name_ + ": ");
            }
            if(this.isEmptyEquipSlot())
            {
               textColor = "#00ff00";
            }
            html = html + ("<font color=\"" + textColor + "\">" + effect.value_ + "</font>");
         }
         return html;
      }
   }
}

class Effect
{
    
   
   public var name_:String;
   
   public var value_:String;
   
   function Effect(name:String, value:String)
   {
      super();
      this.name_ = name;
      this.value_ = value;
   }
}

class Restriction
{
    
   
   public var text_:String;
   
   public var color_:uint;
   
   public var bold_:Boolean;
   
   function Restriction(text:String, color:uint, bold:Boolean)
   {
      super();
      this.text_ = text;
      this.color_ = color;
      this.bold_ = bold;
   }
}

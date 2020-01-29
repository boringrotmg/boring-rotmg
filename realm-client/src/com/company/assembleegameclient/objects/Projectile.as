package com.company.assembleegameclient.objects
{
   import com.company.assembleegameclient.engine3d.Point3D;
   import com.company.assembleegameclient.map.Camera;
   import com.company.assembleegameclient.map.Map;
   import com.company.assembleegameclient.map.Square;
   import com.company.assembleegameclient.objects.particles.HitEffect;
   import com.company.assembleegameclient.objects.particles.SparkParticle;
   import com.company.assembleegameclient.parameters.Parameters;
   import com.company.assembleegameclient.tutorial.Tutorial;
   import com.company.assembleegameclient.tutorial.doneAction;
   import com.company.assembleegameclient.util.BloodComposition;
   import com.company.assembleegameclient.util.FreeList;
   import com.company.assembleegameclient.util.RandomUtil;
   import com.company.assembleegameclient.util.TextureRedrawer;
   import com.company.util.GraphicsUtil;
   import com.company.util.Trig;
   import flash.display.BitmapData;
   import flash.display.GradientType;
   import flash.display.GraphicsGradientFill;
   import flash.display.GraphicsPath;
   import flash.display.IGraphicsData;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Vector3D;
   import flash.utils.Dictionary;
   
   public class Projectile extends BasicObject
   {
      
      private static var objBullIdToObjId_:Dictionary = new Dictionary();
      
      public var props_:ObjectProperties;
      public var containerProps_:ObjectProperties;
      public var projProps_:ProjectileProperties;
      public var texture_:BitmapData;
      public var bulletId_:uint;
      public var ownerId_:int;
      public var containerType_:int;
      public var bulletType_:uint;
      public var damagesEnemies_:Boolean;
      public var damagesPlayers_:Boolean;
      public var damage_:int;
      public var sound_:String;
      public var startX_:Number;
      public var startY_:Number;
      public var startTime_:int;
      public var angle_:Number = 0;
      public var multiHitDict_:Dictionary;
      public var p_:Point3D;
      private var staticPoint_:Point;
      private var staticVector3D_:Vector3D;
      protected var shadowGradientFill_:GraphicsGradientFill;
      protected var shadowPath_:GraphicsPath;
      
      public function Projectile()
      {
         this.p_ = new Point3D(100);
         this.staticPoint_ = new Point();
         this.staticVector3D_ = new Vector3D();
         this.shadowGradientFill_ = new GraphicsGradientFill(GradientType.RADIAL,[0,0],[0.5,0],null,new Matrix());
         this.shadowPath_ = new GraphicsPath(GraphicsUtil.QUAD_COMMANDS,new Vector.<Number>());
         super();
      }
      
      public static function findObjId(ownerId:int, bulletId:uint) : int
      {
         return objBullIdToObjId_[bulletId << 24 | ownerId];
      }
      
      public static function getNewObjId(ownerId:int, bulletId:uint) : int
      {
         var objId:int = getNextFakeObjectId();
         objBullIdToObjId_[bulletId << 24 | ownerId] = objId;
         return objId;
      }
      
      public static function removeObjId(ownerId:int, bulletId:uint) : void
      {
         delete objBullIdToObjId_[bulletId << 24 | ownerId];
      }
      
      public static function dispose() : void
      {
         objBullIdToObjId_ = new Dictionary();
      }
      
      public function reset(containerType:int, bulletType:int, ownerId:int, bulletId:int, angle:Number, startTime:int) : void
      {
         var size:Number = NaN;
         clear();
         this.containerType_ = containerType;
         this.bulletType_ = bulletType;
         this.ownerId_ = ownerId;
         this.bulletId_ = bulletId;
         this.angle_ = Trig.boundToPI(angle);
         this.startTime_ = startTime;
         objectId_ = getNewObjId(this.ownerId_,this.bulletId_);
         z_ = 0.5;
         this.containerProps_ = ObjectLibrary.propsLibrary_[this.containerType_];
         this.projProps_ = this.containerProps_.projectiles_[bulletType];
         this.props_ = ObjectLibrary.getPropsFromId(this.projProps_.objectId_);
         hasShadow_ = this.props_.shadowSize_ > 0;
         var textureData:TextureData = ObjectLibrary.typeToTextureData_[this.props_.type_];
         this.texture_ = textureData.getTexture(objectId_);
         this.damagesPlayers_ = this.containerProps_.isEnemy_;
         this.damagesEnemies_ = !this.damagesPlayers_;
         this.sound_ = this.containerProps_.oldSound_;
         this.multiHitDict_ = this.projProps_.multiHit_ ? new Dictionary() : null;
         if(this.projProps_.size_ >= 0)
         {
            size = this.projProps_.size_;
         }
         else
         {
            size = ObjectLibrary.getSizeFromType(this.containerType_);
         }
         this.p_.setSize(8 * (size / 100));
         this.damage_ = 0;
      }
      
      public function setDamage(damage:int) : void
      {
         this.damage_ = damage;
      }
      
      override public function addTo(map:Map, x:Number, y:Number) : Boolean
      {
         var player:Player = null;
         this.startX_ = x;
         this.startY_ = y;
         if(!super.addTo(map,x,y))
         {
            return false;
         }
         if(!this.containerProps_.flying_ && square_.sink_)
         {
            if (square_.obj_ && square_.obj_.props_.protectFromSink_)
            {
               z_ = 0.5;
            }
            else
            {
               z_ = 0.1;
            }
         }
         else
         {
            player = map.goDict_[this.ownerId_] as Player;
            if(player != null && player.sinkLevel_ > 0)
            {
               z_ = (0.5 - (0.4 * (player.sinkLevel_ / Parameters.MAX_SINK_LEVEL)));
            }
         }
         return true;
      }
      
      public function moveTo(x:Number, y:Number) : Boolean
      {
         var square:Square = map_.getSquare(x,y);
         if(square == null)
         {
            return false;
         }
         x_ = x;
         y_ = y;
         square_ = square;
         return true;
      }
      
      override public function removeFromMap() : void
      {
         super.removeFromMap();
         removeObjId(this.ownerId_,this.bulletId_);
         this.multiHitDict_ = null;
         FreeList.deleteObject(this);
      }
      
      private function positionAt(elapsed:int, p:Point) : void
      {
         var periodFactor:Number = NaN;
         var amplitudeFactor:Number = NaN;
         var theta:Number = NaN;
         var t:Number = NaN;
         var x:Number = NaN;
         var y:Number = NaN;
         var sin:Number = NaN;
         var cos:Number = NaN;
         var halfway:Number = NaN;
         var deflection:Number = NaN;
         p.x = this.startX_;
         p.y = this.startY_;
         var dist:Number = elapsed * (this.projProps_.speed_ / 10000);
         var phase:Number = this.bulletId_ % 2 == 0?Number(0):Number(Math.PI);
         if(this.projProps_.wavy_)
         {
            periodFactor = 6 * Math.PI;
            amplitudeFactor = Math.PI / 64;
            theta = this.angle_ + amplitudeFactor * Math.sin(phase + periodFactor * elapsed / 1000);
            p.x = p.x + dist * Math.cos(theta);
            p.y = p.y + dist * Math.sin(theta);
         }
         else if(this.projProps_.parametric_)
         {
            t = elapsed / this.projProps_.lifetime_ * 2 * Math.PI;
            x = Math.sin(t) * (Boolean(this.bulletId_ % 2)?1:-1);
            y = Math.sin(2 * t) * (this.bulletId_ % 4 < 2?1:-1);
            sin = Math.sin(this.angle_);
            cos = Math.cos(this.angle_);
            p.x = p.x + (x * cos - y * sin) * this.projProps_.magnitude_;
            p.y = p.y + (x * sin + y * cos) * this.projProps_.magnitude_;
         }
         else
         {
            if(this.projProps_.boomerang_)
            {
               halfway = this.projProps_.lifetime_ * (this.projProps_.speed_ / 10000) / 2;
               if(dist > halfway)
               {
                  dist = halfway - (dist - halfway);
               }
            }
            p.x = p.x + dist * Math.cos(this.angle_);
            p.y = p.y + dist * Math.sin(this.angle_);
            if(this.projProps_.amplitude_ != 0)
            {
               deflection = this.projProps_.amplitude_ * Math.sin(phase + elapsed / this.projProps_.lifetime_ * this.projProps_.frequency_ * 2 * Math.PI);
               p.x = p.x + deflection * Math.cos(this.angle_ + Math.PI / 2);
               p.y = p.y + deflection * Math.sin(this.angle_ + Math.PI / 2);
            }
         }
      }
      
      override public function update(time:int, dt:int) : Boolean
      {
         var colors:Vector.<uint> = null;
         var player:Player = null;
         var isPlayer:Boolean = false;
         var isTargetAnEnemy:Boolean = false;
         var sendMessage:Boolean = false;
         var d:int = 0;
         var dead:Boolean = false;
         var elapsed:int = time - this.startTime_;
         if(elapsed > this.projProps_.lifetime_)
         {
            return false;
         }
         var p:Point = this.staticPoint_;
         this.positionAt(elapsed,p);
         if(!this.moveTo(p.x,p.y) || square_.tileType_ == 255)
         {
            if(this.damagesPlayers_)
            {
               map_.gs_.gsc_.squareHit(time,this.bulletId_,this.ownerId_);
            }
            else if(square_.obj_ != null)
            {
               if (Parameters.data_.eyeCandyParticles) {
                  colors = BloodComposition.getColors(this.texture_);
                  map_.addObj(new HitEffect(colors, 100, 3, this.angle_, this.projProps_.speed_), p.x, p.y);
               }
            }
            return false;
         }
         if(square_.obj_ != null && (!square_.obj_.props_.isEnemy_ || !this.damagesEnemies_) && (square_.obj_.props_.enemyOccupySquare_ || !this.projProps_.passesCover_ && square_.obj_.props_.occupySquare_))
         {
            if(this.damagesPlayers_)
            {
               map_.gs_.gsc_.otherHit(time,this.bulletId_,this.ownerId_,square_.obj_.objectId_);
            }
            else
            {
               if (Parameters.data_.eyeCandyParticles) {
                  colors = BloodComposition.getColors(this.texture_);
                  map_.addObj(new HitEffect(colors, 100, 3, this.angle_, this.projProps_.speed_), p.x, p.y);
               }
            }
            return false;
         }
         var target:GameObject = this.getHit(p.x,p.y);
         if(target != null)
         {
            player = map_.player_;
            isPlayer = player != null;
            isTargetAnEnemy = target.props_.isEnemy_;
            sendMessage = isPlayer && !player.isPaused() && (this.damagesPlayers_ || isTargetAnEnemy && this.ownerId_ == player.objectId_);
            if(sendMessage)
            {
               d = GameObject.damageWithDefense(this.damage_,target.defense_,this.projProps_.armorPiercing_,target.condition_);
               dead = false;
               if(target.hp_ <= d)
               {
                  dead = true;
                  if(target.props_.isEnemy_)
                  {
                     doneAction(map_.gs_,Tutorial.KILL_ACTION);
                  }
               }
               if(target == player)
               {
                  map_.gs_.gsc_.playerHit(this.bulletId_,this.ownerId_);
                  target.damage(this.containerType_,d,this.projProps_.effects_,false,this);
               }
               else if(target.props_.isEnemy_)
               {
                  map_.gs_.gsc_.enemyHit(time,this.bulletId_,target.objectId_,dead);
                  target.damage(this.containerType_,d,this.projProps_.effects_,dead,this);
               }
               else if(!this.projProps_.multiHit_)
               {
                  map_.gs_.gsc_.otherHit(time,this.bulletId_,this.ownerId_,target.objectId_);
               }
            }
            if(this.projProps_.multiHit_)
            {
               this.multiHitDict_[target] = true;
            }
            else
            {
               return false;
            }
         }
         return true;
      }
      
      public function getHit(pX:Number, pY:Number) : GameObject
      {
         var go:GameObject = null;
         var xDiff:Number = NaN;
         var yDiff:Number = NaN;
         var dist:Number = NaN;
         var minDist:Number = Number.MAX_VALUE;
         var minGO:GameObject = null;

         if (damagesEnemies_)
         {
            for each(go in map_.hitTEnemies_)
            {
               xDiff = go.x_ > pX?Number(go.x_ - pX):Number(pX - go.x_);
               yDiff = go.y_ > pY?Number(go.y_ - pY):Number(pY - go.y_);
               if(!(xDiff > go.radius_ || yDiff > go.radius_))
               {
                  if(!(this.projProps_.multiHit_ && this.multiHitDict_[go] != null))
                  {
                     dist = Math.sqrt(xDiff * xDiff + yDiff * yDiff);
                     if(dist < minDist)
                     {
                        minDist = dist;
                        minGO = go;
                     }
                  }
               }
            }
         }
         else if (damagesPlayers_)
         {
            for each(go in map_.hitTPlayers_)
            {
               xDiff = go.x_ > pX?Number(go.x_ - pX):Number(pX - go.x_);
               yDiff = go.y_ > pY?Number(go.y_ - pY):Number(pY - go.y_);
               if(!(xDiff > go.radius_ || yDiff > go.radius_))
               {
                  if(!(this.projProps_.multiHit_ && this.multiHitDict_[go] != null))
                  {
                     if(go == map_.player_)
                     {
                        return go;
                     }
                     dist = Math.sqrt(xDiff * xDiff + yDiff * yDiff);
                     if(dist < minDist)
                     {
                        minDist = dist;
                        minGO = go;
                     }
                  }
               }
            }
         }

         /*for each(go in map_.goDict_)
         {
            if(!go.isInvincible())
            {
               if(!go.isStasis())
               {
                  if(this.damagesEnemies_ && go.props_.isEnemy_ || this.damagesPlayers_ && go.props_.isPlayer_)
                  {
                     if(!(go.dead_ || go.isPaused()))
                     {
                        xDiff = go.x_ > pX?Number(go.x_ - pX):Number(pX - go.x_);
                        yDiff = go.y_ > pY?Number(go.y_ - pY):Number(pY - go.y_);
                        if(!(xDiff > go.radius_ || yDiff > go.radius_))
                        {
                           if(!(this.projProps_.multiHit_ && this.multiHitDict_[go] != null))
                           {
                              if(go == map_.player_)
                              {
                                 return go;
                              }
                              dist = Math.sqrt(xDiff * xDiff + yDiff * yDiff);
                              if(dist < minDist)
                              {
                                 minDist = dist;
                                 minGO = go;
                              }
                           }
                        }
                     }
                  }
               }
            }
         }*/
         return minGO;
      }
      
      override public function draw(graphicsData:Vector.<IGraphicsData>, camera:Camera, time:int) : void
      {
         var texture:BitmapData = this.texture_;

         var r:Number = this.props_.rotation_ == 0?Number(0):Number(time / this.props_.rotation_);
         this.staticVector3D_.x = x_;
         this.staticVector3D_.y = y_;
         this.staticVector3D_.z = z_;
         this.p_.draw(graphicsData,this.staticVector3D_,this.angle_ - camera.angleRad_ + this.props_.angleCorrection_ + r,camera.wToS_,camera,texture);
         if(this.projProps_.particleTrail_)
         {
            if (Parameters.data_.eyeCandyParticles)
            {
               map_.addObj(new SparkParticle(100, 16711935, 600, 0.5, RandomUtil.plusMinus(3), RandomUtil.plusMinus(3)), x_, y_);
               map_.addObj(new SparkParticle(100, 16711935, 600, 0.5, RandomUtil.plusMinus(3), RandomUtil.plusMinus(3)), x_, y_);
               map_.addObj(new SparkParticle(100, 16711935, 600, 0.5, RandomUtil.plusMinus(3), RandomUtil.plusMinus(3)), x_, y_);
            }
         }
      }
      
      override public function drawShadow(graphicsData:Vector.<IGraphicsData>, camera:Camera, time:int) : void
      {
         var s:Number = this.props_.shadowSize_ / 400;
         var w:Number = 30 * s;
         var h:Number = 15 * s;
         this.shadowGradientFill_.matrix.createGradientBox(w * 2,h * 2,0,posS_[0] - w,posS_[1] - h);
         graphicsData.push(this.shadowGradientFill_);
         this.shadowPath_.data.length = 0;
         this.shadowPath_.data.push(posS_[0] - w,posS_[1] - h,posS_[0] + w,posS_[1] - h,posS_[0] + w,posS_[1] + h,posS_[0] - w,posS_[1] + h);
         graphicsData.push(this.shadowPath_);
         graphicsData.push(GraphicsUtil.END_FILL);
      }
   }
}

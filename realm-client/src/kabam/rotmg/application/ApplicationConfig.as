package kabam.rotmg.application
{
import kabam.rotmg.application.impl.ReleaseSetup;

import org.swiftsuspenders.Injector;

import flash.display.DisplayObjectContainer;
import flash.display.LoaderInfo;

import kabam.rotmg.application.api.ApplicationSetup;

import org.swiftsuspenders.Injector;

import robotlegs.bender.framework.api.IConfig;

public class ApplicationConfig implements IConfig
{

    [Inject]
    public var injector:Injector;
    [Inject]
    public var root:DisplayObjectContainer;
    [Inject]
    public var loaderInfo:LoaderInfo;


    public function configure():void {
        var setup:ApplicationSetup = this.makeAppSetup();
        this.injector.map(ApplicationSetup).toValue(setup);
    }

    private function makeAppSetup():ApplicationSetup
    {
        return new ReleaseSetup();
    }
}
}

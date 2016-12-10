#include "%POUND_INCL%"

#include <ds/app/environment.h>
#include <ds/ui/sprite/sprite_engine.h>
#include <ds/debug/logger.h>

#include "app/app_defs.h"
#include "app/globals.h"
#include "events/app_events.h"

//#include "ds/ui/interface_xml/interface_xml_importer.h"

namespace %NAMESPACE%{

%CLASSNAME%::%CLASSNAME%(Globals& g)
	: ds::ui::Sprite(g.mEngine)
	, mGlobals(g)
	, mEventClient(g.mEngine.getNotifier(), [this](const ds::Event *m){ if(m) this->onAppEvent(*m); })
{
	animateOn();
}

void %CLASSNAME%::onAppEvent(const ds::Event& in_e){
	if(in_e.mWhat == IdleEndedEvent::WHAT()){
		const IdleEndedEvent& e((const IdleEndedEvent&)in_e);
		animateOn();
	} else if(in_e.mWhat == IdleStartedEvent::WHAT()){
		animateOff();
	}
}

void %CLASSNAME%::layout(){
}

void %CLASSNAME%::animateOn(){
	show();
	tweenOpacity(1.0f, mGlobals.getAnimDur());

	// Recursively animate on any children, including the primary layout
	//tweenAnimateOn(true, 0.0f, 0.05f);
}

void %CLASSNAME%::animateOff(){
	tweenOpacity(0.0f, mGlobals.getAnimDur(), 0.0f, ci::EaseNone(), [this]{hide(); });
}

void %CLASSNAME%::updateServer(const ds::UpdateParams& p){
	ds::ui::Sprite::updateServer(p);

	// any changes for this frame happen here
}

}//end namespace %NAMESPACE%

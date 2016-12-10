#pragma once
#ifndef %INCL_GUARD%
#define %INCL_GUARD%

#include <ds/ui/sprite/sprite.h>
#include <ds/app/event_client.h>

namespace %NAMESPACE% {

class Globals;

/*
 * \class %NAMESPACE%::%CLASSNAME%
 *
 */
class %CLASSNAME% final : public ds::ui::Sprite  {
public:
	%CLASSNAME%(Globals& g);

private:
	void								onAppEvent(const ds::Event&);

	virtual void						updateServer(const ds::UpdateParams& p);

	void								animateOn();
	void								animateOff();

	void								layout();

	Globals&							mGlobals;

	ds::EventClient						mEventClient;

};

}//end namespace %NAMESPACE%

#endif //%INCL_GUARD%

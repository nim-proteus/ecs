# ecs

## Entity Component System

The extremum library contains a set of classes that can be used to 
implement a generic Entity Component System. 

Given a Physics simulation, you might expect the following:
 - A component `HasLocation` to track the current location
 - A component `HasAcceleration` to track current velocity
 - A system `Acceleration` to update the location of the Entity based on the velocity

```nim
import ecs
import glm

type
    HasLocation = ref object of Component
        loc: Vec3f

    HasAcceleration = ref object of Component
        accel: Vec3f

    Acceleration = ref object of System
        components: seq[HasAcceleration]

method register(this: Acceleration, c: Component) =
    if c of HasAcceleration:
        components[c.id] = c

method update(this: Acceleration) =
    let elapsed = secondsElapsed()
    for c in components:
        var l = this.getEcs().getComponent[:HasLocation](c.entityId)
        l.loc = l.loc + (c.accel * elapsed)
```
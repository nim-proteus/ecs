# ecs

A Nim-Proteus library.

## Entity Component System

The ecs library contains a set of classes that can be used to 
implement a generic Entity Component System. 

Given a Physics simulation, you might expect the following:
 - A component `HasLocation` to track the current location
 - A component `HasAcceleration` to track current velocity
 - A system `Acceleration` to update the location of the Entity based on the velocity

```nim
import ecs
import std/tables
import glm

type
    HasLocation = ref object of Component
        loc: Vec3f

    HasAcceleration = ref object of Component
        accel: Vec3f

    Acceleration = ref object of System
        components: seq[HasAcceleration]

proc newHasLocation(loc: Vec3f): HasLocation =
    result = new(HasLocation)
    result.loc = loc

proc newHasAcceleration(accel: Vec3f): HasAcceleration =
    result = new(HasAcceleration)
    result.accel = accel

proc newAcceleration(): Acceleration =
    result = new(Acceleration)
    result.components = newSeq[HasAcceleration]()

method register(this: Acceleration, c: Component) =
    if c of HasAcceleration:
        this.components.add((HasAcceleration)c)

method update(this: Acceleration) =
    let elapsed = 0.1f # secondsElapsed()
    for c in this.components:
        var l = this.getEcs().getComponent[:HasLocation](c.entityId)
        l.loc = l.loc + (c.accel * elapsed)

when isMainModule:
    # Create an ecs and register an acceleration system
    var e = newEcs()
    e.register(newAcceleration())

    # Create an entity and give it a location and acceleration
    var t = newEntity()
    e.register(t)
    e.register(t, newHasLocation(vec3f(0, 0, 0)))
    e.register(t, newHasAcceleration(vec3f(0, 5, 0)))
    
    # One tick of the entire ecs
    e.update()

    # And the location should be updated
    var c = e.getComponent[:HasLocation](t.getId())
    echo c.loc.y == 0.5f
```
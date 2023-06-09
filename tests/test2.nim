import unittest
import ecs
import std/tables

type
    Vec3f = object
        x, y, z: float32

    HasLocation = ref object of Component
        loc: Vec3f

    HasAcceleration = ref object of Component
        accel: Vec3f

    Acceleration = ref object of System
        components: seq[HasAcceleration]

proc `*`(a, b: Vec3f): Vec3f =
    result = Vec3f(x: a.x * b.x, y: a.y * b.y, z: a.z * b.z)

proc `*`(a: Vec3f, b: float32): Vec3f =
    result = Vec3f(x: a.x * b, y: a.y * b, z: a.z * b)

proc `+`(a, b: Vec3f): Vec3f =
    result = Vec3f(x: a.x + b.x, y: a.y + b.y, z: a.z + b.z)

proc vec3f(x, y, z: float32): Vec3f =
    result = Vec3f(x: x, y: y, z: z)

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

test "new ecs":
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
    check c.loc.y == 0.5f
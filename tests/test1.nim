import unittest
import ecs
import std/tables

test "new ecs":
    var ecs = newEcs()
    check ecs != nil
    check ecs.entities != nil
    check ecs.components != nil
    check ecs.systems != nil

test "ecs register system":
    var e = newEcs()
    var s = System()
    e.register(s)
    # var ss = ecs.systems[s.getId()]
    check s.getId() == 1
    check e.systems[s.getId()] == s
    e.unregister(s)
    check len(e.systems) == 0

test "ecs register entity":
    var e = newEcs()
    var t = newEntity()
    e.register(t)
    check t.getId() == 1
    check e.entities[t.getId()] == t
    check len(e.entities) == 1
    e.unregister(t)
    check len(e.entities) == 0

test "ecs register component":
    var e = newEcs()
    var t = newEntity()
    var c = Component()
    e.register(t)
    e.register(t, c)
    check c.getId() == 1
    check e.components[c.getId()] == c
    # check len(e.components) == 1
    # e.unregister(t, c)
    # check len(e.components) == 0
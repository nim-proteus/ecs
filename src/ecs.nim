import std/tables

type 
    Ecs* = ref object of RootObj
        systems*: TableRef[SystemId, System]
        entities*: TableRef[EntityId, Entity]
        components*: TableRef[ComponentId, Component]

    System* = ref object of RootObj
        id: SystemId
        ecs: Ecs

    Entity* = ref object of RootObj
        id: EntityId
        components: TableRef[ComponentId, Component]

    Component* = ref object of RootObj
        id: ComponentId
        entityId*: EntityId

    EntityId* = uint
    SystemId* = uint 
    ComponentId* = uint


method register*(this: System, c: Component) {.base.} = discard
method unregister*(this: System, component: Component) {.base.} = discard
method update(this: System) {.base.} = discard

proc register*(this: Ecs, entityId: EntityId, component: Component): ComponentId = 
    var entity = this.entities[entityId]
    component.id = (len(this.components) + 1).ComponentId
    entity.components[component.id] = component
    this.components[component.id] = component
    component.entityId = entity.id
    for i,s in pairs(this.systems):
        s.register(component)
    result = component.id

proc unregister*(this: Ecs, entityId: EntityId, component: Component) = 
    for i,s in pairs(this.systems):
        s.unregister(component)
    var entity = this.entities[entityId]
    entity.components.del(component.id)
    this.components.del(component.id)
    component.entityId = 0

proc register*(this: Ecs, entity: Entity, components: varargs[Component]): EntityId =
    entity.id = (len(this.entities) + 1).EntityId
    this.entities[entity.id] = entity
    for c in components:
        discard this.register(entity.id, c)
    result = entity.id

proc unregister*(this: Ecs, entity: Entity) = 
    var e = this.entities[entity.id]
    for i,c in pairs(e.components):
        this.unregister(e.id, c)
    this.entities.del(entity.id)

proc getComponent*[T: Component](this: Ecs, entityId: EntityId): T =
    var entity = this.entities[entityId]
    if entity == nil:
        return nil
    
    for i,c in pairs(entity.components):
        if c of T:
            return c.T

    return nil


proc getId*(this: System): SystemId = this.id

proc getEcs*(this: System): Ecs = this.ecs

proc setEcs*(this: System, ecs: Ecs) = this.ecs = ecs

proc getId*(this: Entity): EntityId = this.id

proc getId*(this: Component): ComponentId = this.id

proc newEntity*(): Entity =
    result = new(Entity)
    result.components = newTable[EntityId, Component]()

proc newEcs*(): Ecs =
    result = new(Ecs)
    result.components = newTable[ComponentId, Component]()
    result.entities = newTable[EntityId, Entity]()
    result.systems = newTable[SystemId, System]()

proc update*(this: Ecs) = 
    for i, s in pairs(this.systems):
        s.update()

proc register*(this: Ecs, systems: varargs[System]) = 
    for system in systems:
        system.id = (len(this.systems) + 1).SystemId
        this.systems[system.id] = system
        system.setEcs(this)

proc unregister*(this: Ecs, system: System) = 
    this.systems.del(system.id)


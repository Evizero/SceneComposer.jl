module SceneComposer

using StaticArrays
using CoordinateTransformations
using Rotations

export

    SceneNode,
    Vector3D,
    Quat

const Vector3D{T} = SVector{3,T}

mutable struct SceneNode{T}
    parent::Nullable{SceneNode{T}}
    children::Vector{SceneNode{T}}
    local_position::Vector3D{T}
    local_orientation::Quat{T}
    local_scale::Vector3D{T}
    global_position::Vector3D{T}
    global_orientation::Quat{T}
    global_scale::Vector3D{T}

    function SceneNode(position::Vector3D{T} = Vector3D(0.,0,0),
                       orientation::Quat{T} = Quat(1.,0,0,0),
                       scale::Vector3D{T} = Vector3D(1.,1,1)) where T
        new{T}(
            Nullable{SceneNode{T}}(),
            SceneNode{T}[],
            position,
            orientation,
            scale,
            position,
            orientation,
            scale,
        )
    end
end

function Base.show(io::IO, node::SceneNode)
    println(io, summary(node))
    println(io, " hierachy")
    println(io, "  - parent: ", !isnull(node.parent))
    println(io, "  - children: ", length(node.children))
    if !isnull(node.parent)
        println(io, " local")
        println(io, "  - position: ", node.local_position)
        println(io, "  - orientation: ", node.local_orientation)
        println(io, "  - scale: ", node.local_scale)
    end
    println(io, " global")
    println(io, "  - position: ", node.global_position)
    println(io, "  - orientation: ", node.global_orientation)
    print(io, "  - scale: ", node.global_scale)
end

function update_global!(node::SceneNode)
    if isnull(node.parent)
        # no parent means that local == global
        node.global_position = node.local_position
        node.global_orientation = node.local_orientation
        node.global_scale = node.local_scale
    else
        # cache global values using the local relative to parent
        parent = get(node.parent)
        node.global_scale = node.local_scale .* parent.global_scale
        node.global_orientation = parent.global_orientation * node.local_orientation
        node.global_position = parent.global_position .+ (parent.global_orientation * (node.local_position .* parent.global_scale))
    end
    foreach(update_global!, node.children)
    node
end

function detach_parent!(node::SceneNode{T}, update=true) where T
    if !isnull(node.parent)
        # remove from parents children list
        parent_children = get(node.parent).children
        for i in 1:length(parent_children)
            if parent_children[i] == node
                deleteat!(parent_children, i)
                break
            end
        end
        # set new parent as null
        node.parent = Nullable{SceneNode{T}}()
    end
    update && update_global!(child)
    node
end

function attach_parent!(child::SceneNode{T}, parent::SceneNode{T}) where T
    # detach child from its current parent (without re-caching)
    detach_parent!(child, false)
    # attach child to new parent
    push!(parent.children, child)
    child.parent = Nullable{SceneNode{T}}(parent)
    update_global!(child)
    child
end

# package code goes here

end # module

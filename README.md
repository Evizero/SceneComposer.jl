# SceneComposer

[![Build Status](https://travis-ci.org/Evizero/SceneComposer.jl.svg?branch=master)](https://travis-ci.org/Evizero/SceneComposer.jl)
[![Coverage Status](https://coveralls.io/repos/Evizero/SceneComposer.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/Evizero/SceneComposer.jl?branch=master)
[![codecov.io](http://codecov.io/github/Evizero/SceneComposer.jl/coverage.svg?branch=master)](http://codecov.io/github/Evizero/SceneComposer.jl?branch=master)

Its possible to build a hierachy of `SceneNode`. Each node tracks
its own local position, orientation, and scale (local to their
parent). If a node is an orphan its local properties are its
global properties.

```
julia> node1 = SceneNode(Vector3D(2.,1,-2), Quat(RotX(0.1)))
SceneComposer.SceneNode{Float64}
 hierachy
  - parent: false
  - children: 0
 global
  - position: [2.0, 1.0, -2.0]
  - orientation: Quat(0.99875, 0.0499792, 0.0, 0.0)
  - scale: [1.0, 1.0, 1.0]

julia> node2 = SceneNode(Vector3D(-0.5, 0.2, 1.0))
SceneComposer.SceneNode{Float64}
 hierachy
  - parent: false
  - children: 0
 global
  - position: [-0.5, 0.2, 1.0]
  - orientation: Quat(1.0, 0.0, 0.0, 0.0)
  - scale: [1.0, 1.0, 1.0]
```

Nodes can be attached to other nodes. A node can only have a
single parent, but each node can have any number of children
(including 0). When attaching or detaching a node, the global
properties are computed recursively from the local properties.

```
julia> SceneComposer.attach_parent!(node2, node1);

julia> node2
SceneComposer.SceneNode{Float64}
 hierachy
  - parent: true
  - children: 0
 local
  - position: [-0.5, 0.2, 1.0]
  - orientation: Quat(1.0, 0.0, 0.0, 0.0)
  - scale: [1.0, 1.0, 1.0]
 global
  - position: [1.5, 1.09917, -0.985029]
  - orientation: Quat(0.99875, 0.0499792, 0.0, 0.0)
  - scale: [1.0, 1.0, 1.0]
```

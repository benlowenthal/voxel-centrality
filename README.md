# Voxel Centrality
A Teardown mod for physics estimations of rigid body voxel structures using a performant betweenness centrality implementation.

Written in Lua scripting language and served as a useful way to explore Lua and graph centrality, and optimising it for interactive frame rates.

1. Installation
2. Options
3. Limitations
4. Credits

=========================

1. Installation

Place all files in an unzipped folder inside Teardown's mod directory. 

=========================

2. Options

"Damage threshold" refers to the minimum limit, above which voxels are broken.
"Samples per shape" is the fixed number of samples taken from each voxel structure. This is to improve performance scaling.
"Iterations per frame" is how many centrality samples are looked at every frame. Has a large impact on performance but makes centrality calculations finish faster.
"Min shape size" is the minimum number of voxels a shape must have to be simulated.

=========================

3. Limitations

Due to the nature of using centrality as a weighting measure, voxels near the corners of a shape can sometimes be under the break threshold even when it looks like they shouldn't. And by weighting by y-position to emulate gravity, a Shape connected in the top corners is unlikely to reach the threshold. I have tried to weight the factors by constants to make them as in proportion as possible but edge cases may not work as expected.
Using the Teardown API it is not possible to find inter-Shape connections, even if they are within a single Body. Therefore separate Shapes are considered individually the edges are treated as if they are not attached to anything.
Additionally, MakeHoles() is fairly frame-rate intensive, thus big areas that are broken can cause frame drops. Unfortunately this is not under my control and if it was possible to improve its performance or reimplement it manually in Lua I would.

=========================

4. Credits

All work was created and published by me, Ben Lowenthal.

No acknowledgement is required should you modify and release this code, but it would be appreciated.

The AS-Brandes algorithm was adapted from pseudocode in the paper "Path Centrality: A New Centrality Measure in Social Networks".
Uses the generic optionsSlider function from "Wwadlol"s Structural Integrity Test mod.

# Voxel Centrality
A Teardown mod for physics estimations of rigid body voxel structures using a performant betweenness centrality implementation.

Written in Lua scripting language and served as a useful way to explore Lua and graph centrality, and optimising it for interactive frame rates.

1. Installation
2. Options
3. Implementation details
4. Limitations
5. Credits

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

3. Implementation details

--TODO

=========================

4. Limitations

--TODO

=========================

5. Credits

All work was created and published by me, Ben Lowenthal.

No acknowledgement is required should you modify and release this code, but it would be appreciated.

The AS-Brandes algorithm was adapted from pseudocode in the paper "Path Centrality: A New Centrality Measure in Social Networks".

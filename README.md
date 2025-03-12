# 2025-Ratiometric
Desai Lab

This repository includes code measuring pH microenvironment of ejected vacuoles using a ratiometric fluorescent marker.  Each macro determines the ratio of yellow-to-blue in single vacuole images.  Because vacuoles differ greatly in size, shape, intensity, and features, segmentation is difficult.  Thus each macro employs a different strategy.

Macro 1 segments all cells using classical thresholding and identifies problematic cells; should be used in connection with Macro 2.
Macro 2 allows human-in-the-loop editing of the problematic cells identified with Macro 1; should be used in connection with Macro 1.
Macro 3 uses human-in-the-loop editing of all images.



class TreeLeafAnchor {
  final double x;
  final double y;
  final double rotation;

  const TreeLeafAnchor({
    required this.x,
    required this.y,
    required this.rotation,
  });
}

/// Leaf positions for the 1278 x 1230 tree.png.
///
/// x:
///   0.0 = far left
///   1.0 = far right
///
/// y:
///   0.0 = top
///   1.0 = bottom
///
/// Each position is normalized, so the leaves remain attached
/// to the same part of the tree on different screen sizes.
const List<TreeLeafAnchor> treeLeafAnchors = [

  
  

  TreeLeafAnchor(x: 0.402, y: 0.500, rotation: -0.6), // 01
  TreeLeafAnchor(x: 0.415, y: 0.530, rotation: -1.7), // 02
  // TreeLeafAnchor(x: 0.420, y: 0.500, rotation: 0), // 03
  TreeLeafAnchor(x: 0.445, y: 0.550, rotation: 0.0), // 04

  TreeLeafAnchor(x: 0.317, y: 0.499, rotation:- 1.7), // 05
  TreeLeafAnchor(x: 0.310, y: 0.460, rotation: 0), // 06
  TreeLeafAnchor(x: 0.352, y: 0.520, rotation: 0), // 07
  TreeLeafAnchor(x: 0.290, y: 0.44, rotation: -0.7), // 08

  // ============================================================
  // MIDDLE LEFT
  // ============================================================

  TreeLeafAnchor(x: 0.208, y: 0.390, rotation: -0.35), // 9

  TreeLeafAnchor(x: 0.650, y: 0.500, rotation: -0.35), // 10

  TreeLeafAnchor(x: 0.650, y: 0.430, rotation: 0), // 11
  TreeLeafAnchor(x: 0.540, y: 0.429, rotation: 0),  // 12
  TreeLeafAnchor(x: 0.577, y: 0.330, rotation: -0.50), // 13
  TreeLeafAnchor(x: 0.618, y: 0.300, rotation: -0.50), // 14
  TreeLeafAnchor(x: 0.236, y: 0.310, rotation: -0.30), // 015
  TreeLeafAnchor(x: 0.150, y: 0.350, rotation: -1.3),  // 016
  TreeLeafAnchor(x: 0.174, y: 0.365, rotation: 0), // 017

  TreeLeafAnchor(x: 0.420, y: 0.185, rotation: -0.5),  // 018
  TreeLeafAnchor(x: 0.40, y: 0.170, rotation: -2.0), // 019
  TreeLeafAnchor(x: 0.462, y: 0.360, rotation:- 0.5), // 020

  TreeLeafAnchor(x: 0.480, y: 0.350, rotation: -0.4),  //   021
  TreeLeafAnchor(x: 0.429, y: 0.330, rotation: -0.40),  // 022
  TreeLeafAnchor(x: 0.450, y: 0.300, rotation: -0.25), // 023
  TreeLeafAnchor(x: 0.390, y: 0.275, rotation: 0.4), // 024
  TreeLeafAnchor(x: 0.369, y: 0.260, rotation: -0.5), // 025
  TreeLeafAnchor(x: 0.218, y: 0.220, rotation: -0.72),  //  026
  TreeLeafAnchor(x: 0.250, y: 0.230, rotation: -0.8), // 27

  // ============================================================
  // MIDDLE RIGHT
  // ============================================================
  TreeLeafAnchor(x: 0.145, y: 0.240, rotation: 3.5),  // 028

  TreeLeafAnchor(x: 0.140, y: 0.200, rotation: -1.80),  // 029
  TreeLeafAnchor(x: 0.155, y: 0.220, rotation: 0.100), // 30
  TreeLeafAnchor(x: 0.310, y: 0.220, rotation: 0), // 031
  TreeLeafAnchor(x: 0.100, y: 0.490, rotation: -1.5), // 032
  TreeLeafAnchor(x: 0.135, y: 0.445, rotation: -0.9), // 33

  TreeLeafAnchor(x: 0.060, y: 0.400, rotation: -0.5), // 034
  TreeLeafAnchor(x: 0.040, y: 0.405, rotation: -1.5), // 035
  TreeLeafAnchor(x: 0.040, y: 0.450, rotation: -2.5), // 036
  TreeLeafAnchor(x: 0.040, y: 0.520, rotation: -2.7), // 037
  TreeLeafAnchor(x: 0.276, y: 0.150, rotation: -0.5), // 038
  TreeLeafAnchor(x: 0.535, y: 0.225, rotation: -0.3), // 039
  TreeLeafAnchor(x: 0.494, y: 0.160, rotation: -0.55), // 040

  TreeLeafAnchor(x: 0.500, y: 0.178, rotation: 0.45), // 041
  TreeLeafAnchor(x: 00.365, y: 0.100, rotation: -2), // 042
  TreeLeafAnchor(x: 0.390, y: 0.100, rotation: 0), // 043

  TreeLeafAnchor(x: 0.613, y: 0.250, rotation: 1.2), // 044
  TreeLeafAnchor(x: 0.600, y: 0.225, rotation: 0.8), // 045
  TreeLeafAnchor(x: 0.450, y: 0.090, rotation: 0), // 046
  TreeLeafAnchor(x: 0.425, y: 0.020, rotation: -0.5), // 047

  TreeLeafAnchor(x: 0.550, y: 0.106, rotation: -0.5), // 048
  TreeLeafAnchor(x: 0.567, y: 0.100, rotation: 0), // 049

  // ============================================================
  // LOWER LEFT
  // ============================================================

  TreeLeafAnchor(x: 0.720, y: 0.380, rotation: -1.50), // 050
  TreeLeafAnchor(x: 0.750, y: 0.370, rotation: -0.35), // 051
  TreeLeafAnchor(x: 0.760, y: 0.433, rotation: 0.8),
   // 052
  TreeLeafAnchor(x: 0.750, y: 0.375, rotation: 0.8), // 053

  TreeLeafAnchor(x: 0.620, y: 0.138, rotation: 0), // 054
  TreeLeafAnchor(x: 0.600, y: 0.140, rotation: 0), // 055
  
  TreeLeafAnchor(x: 0.687, y: 0.140, rotation: -0.4),  // 056
  TreeLeafAnchor(x: 0.718, y: 0.105, rotation: -0.4), // 057
  TreeLeafAnchor(x: 0.730, y: 0.115, rotation: 0), // 058

  TreeLeafAnchor(x: 0.740, y: 0.130, rotation: 1.0), // 059
  TreeLeafAnchor(x: 0.754, y: 0.275, rotation: -0.0), // 060

  TreeLeafAnchor(x: 0.675, y: 0.530, rotation: 1.0),  // 061
  TreeLeafAnchor(x: 0.810, y: 0.325, rotation: 2.5), // 062
  TreeLeafAnchor(x: 0.885, y: 0.520, rotation: 2.5), // 063
  TreeLeafAnchor(x: 0.890, y: 0.460, rotation: 0.41), // 064
  TreeLeafAnchor(x: 0.726, y: 0.215, rotation: 0.50),  // 065

  TreeLeafAnchor(x: 0.841, y: 0.224, rotation: 0.45), // 066
  TreeLeafAnchor(x: 0.820, y: 0.200, rotation: 0.25),  // 067

  // ============================================================
  // LOWER RIGHT
  // ============================================================

  TreeLeafAnchor(x: 0.695, y: 0.695, rotation: 2.0), // 068
  TreeLeafAnchor(x: 0.710, y: 0.691, rotation: 0.40), // 069

  TreeLeafAnchor(x: 0.813, y: 0.685, rotation: 2.2),// 070
  TreeLeafAnchor(x: 0.860, y: 0.678, rotation: 1.9), // 71

  TreeLeafAnchor(x: 0.870, y: 0.638, rotation: 1.5), // 72
  TreeLeafAnchor(x: 0.670, y: 0.663, rotation: 0.60), // 73
  TreeLeafAnchor(x: 0.622, y: 0.528, rotation: -1.3), // 74
  TreeLeafAnchor(x: 0.640, y: 0.490, rotation: -1.7), // 75


  TreeLeafAnchor(x: 0.880, y: 0.634, rotation: 0.35), // 76

  TreeLeafAnchor(x: 0.850, y: 0.607, rotation: 0.40), // 77

  TreeLeafAnchor(x: 0.820, y: 0.580, rotation: 0), // 78

  TreeLeafAnchor(x: 0.695, y: 0.500, rotation: 0), // 79

  TreeLeafAnchor(x: 0.955, y: 0.555, rotation: 2.0), // 80

  TreeLeafAnchor(x: 0.940, y: 0.535, rotation: 1.35), // 81

  TreeLeafAnchor(x: 0.950, y: 0.470, rotation: 0.7), // 82

  TreeLeafAnchor(x: 0.940, y: 0.408, rotation: 1.5), // 83

  TreeLeafAnchor(x: 0.942, y: 0.375, rotation: 0), // 84
  TreeLeafAnchor(x: 0.911, y: 0.350, rotation: 0), // 84
  TreeLeafAnchor(x: 0.880, y: 0.325, rotation: 0.35), //86 
  TreeLeafAnchor(x: 0.870, y: 0.300, rotation: 0), // 87
  TreeLeafAnchor(x: 0.820, y: 0.280, rotation: 0.30), // 88

  // ============================================================
  // INNER / FILLING BRANCHES
  // ============================================================

  TreeLeafAnchor(x: 0.200, y: 0.560, rotation: 0.1), // 89

  TreeLeafAnchor(x: 0.223, y: 0.658, rotation: 2.0),  // 90
  
  TreeLeafAnchor(x: 0.165, y: 0.545, rotation: -2.3), // 91

  TreeLeafAnchor(x: 0.142, y: 0.585, rotation: -2.0),  // 92
  TreeLeafAnchor(x: 0.130, y: 0.642, rotation: -2.0),  // 93
  TreeLeafAnchor(x: 0.13, y: 0.665, rotation: -2.7),  // 94

  TreeLeafAnchor(x: 0.15, y: 0.680, rotation: 3.0),  // 95

  TreeLeafAnchor(x: 0.21, y: 0.670, rotation: 3.0),  // 96
];
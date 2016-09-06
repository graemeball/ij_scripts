// Overlay_third_grid.ijm
//
// take a user-defined line and draw perpendicular grid
// as overlay, splitting original line into thirds
//
// graemeball@gmail.com
// Creative Commons CC-BY
//

if (selectionType != 5) {
	exit("Draw line selection before running macro!");
}
getSelectionCoordinates(xc, yc);
run("Add Selection...");  // add line to overlay

// eqn of input line, y = mx + c
m = (yc[1] - yc[0]) / (xc[1] - xc[0]);
c = yc[0] - (m * xc[0]);

// points "1" and "2", at 1/3 and 2/3 of distance along line
p1x = xc[0] + (xc[1] - xc[0]) / 3;
p1y = yc[0] + (yc[1] - yc[0]) / 3;
p2x = xc[0] + 2 * (xc[1] - xc[0]) / 3;
p2y =  yc[0] + 2 * (yc[1] - yc[0]) / 3;

// perpendicular lines "1" and "2", with end-points "a" and "b"
m_perp = -1.0 / m;  // slope of perpendicular lines
// "len" is length / distance perpendicular lines radiate from centre
len = sqrt(pow(xc[1] - xc[0], 2) + pow(yc[1] - yc[0], 2)) / 3;
c1 = p1y - m_perp * p1x; // line 1 y-intercept
c2 = p2y - m_perp * p2x; // line 2 y-intercept
// use x' = [x (+/-) len] / sqrt(m^2 + 1)
// (derived from m = delta-y / delta-x and y = mx + c with len constraint)
l1ax = p1x - len / sqrt(pow(m_perp, 2) + 1);
l1ay = m_perp * l1ax + c1;
l1bx = p1x + len / sqrt(pow(m_perp, 2) + 1);
l1by = m_perp * l1bx + c1;
l2ax = p2x - len / sqrt(pow(m_perp, 2) + 1);
l2ay = m_perp * l2ax + c2;
l2bx = p2x + len / sqrt(pow(m_perp, 2) + 1);
l2by = m_perp * l2bx + c2;

// add perp lines to overlay
makeLine(l1ax, l1ay, l1bx, l1by);
run("Add Selection...");
makeLine(l2ax, l2ay, l2bx, l2by);
run("Add Selection...");

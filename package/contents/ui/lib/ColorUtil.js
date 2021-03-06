.pragma library
// Version: 1

// https://stackoverflow.com/questions/9733288/how-to-programmatically-calculate-the-contrast-ratio-between-two-colors
// https://www.w3.org/TR/AERT/#color-contrast
function brightness(c) {
	return (c.r*299 + c.g*587 + c.b*114) / 1000
}

// https://www.w3.org/TR/AERT/#color-contrast
function contrast(c1, c2) {
	return Math.max(c1.r, c2.r) - Math.min(c1.r, c2.r) + Math.max(c1.g, c2.g) - Math.min(c1.g, c2.g) + Math.max(c1.b, c2.b) - Math.min(c1.b, c2.b)
}

// https://www.w3.org/TR/AERT/#color-contrast
// w3 mentions 500 using rgb 255 values. QML rgba is 0..1 however, and 500/255=1.96
function hasEnoughContrast(c1, c2) {
	return contrast(c1, c2) >= 1.96
}

function setAlpha(c, a) {
	return Qt.rgba(c.r, c.g, c.b, a)
}

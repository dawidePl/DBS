float rP(in float theta, in float g) {
    float a = 3.0 * (1.0 + (theta * theta));
    float b = 16.0 * 3.141592;

    return a / b;
}

float mP(in float theta, in float g) {
    float a = 1.0 - (g * g);
    float b = 4.0 * 3.141592 * pow(1 + (g * g) - 2.0 * g * theta, 1.5);

    return a / b;
}

float csP(in float theta, in float g) {
    float a = 3.0 * (1.0 - pow(g, 2.0)) * (1.0 + pow(theta, 2.0));
    float b = 2.0 * pow((2.0 + (g * g)) * (1.0 + (g * g) - 2.0 * g * (theta * theta))), 1.5);

    return (a * b) / (4.0 * 3.141592);
}

vec2 phaseCombined(in float theta, in float g) {
    float rayleigh = rP(theta, g);
    float mie = mP(theta, g);

    return vec2(rayleigh, mie);
}

function dcm = euler2dcm(roll, pitch, yaw, type)

roll=roll*pi/180.0;
pitch=pitch*pi/180.0;
yaw=yaw*pi/180.0;

% Calculate trigonometric values
cr = cos(roll);
sr = sin(roll);
cp = cos(pitch);
sp = sin(pitch);
cy = cos(yaw);
sy = sin(yaw);

% Initialize a 3x3 matrix for the Direction Cosine Matrix
dcm = zeros(3, 3);

% Fill the DCM matrix using the specified formula
switch type
    case 'ZYX'
        dcm(1, 1) = cp * cy;
        dcm(1, 2) = -cr * sy + sr * sp * cy;
        dcm(1, 3) = sr * sy + cr * sp * cy;
        dcm(2, 1) = cp * sy;
        dcm(2, 2) = cr * cy + sr * sp * sy;
        dcm(2, 3) = -sr * cy + cr * sp * sy;
        dcm(3, 1) = -sp;
        dcm(3, 2) = sr * cp;
        dcm(3, 3) = cr * cp;
    case 'ZXY'
        dcm(1, 1) = cy * cr - sy * sp * sr;
        dcm(1, 2) = -cp * sy;
        dcm(1, 3) = cy * sr + cr * sy * sp;
        dcm(2, 1) = cr * sy + cy * sp * sr;
        dcm(2, 2) = cy * cp;
        dcm(2, 3) = sy * sr - cy * cr * sp;
        dcm(3, 1) = -cp * sr;
        dcm(3, 2) = sp;
        dcm(3, 3) = cp * cr;
    otherwise
        error('Unsupported rotation type');
end

end


typedef Matrix<float,3,3> Matrix3x3;
Matrix3x3 m = Matrix3x3::Random();
Matrix3f y = Matrix3f::Random();
cout << "Here is the matrix m:" << endl << m << endl;
cout << "Here is the matrix y:" << endl << y << endl;
Matrix3f x;
if(m.qr().solve(y, &x))
{
  assert(y.isApprox(m*x));
  cout << "Here is a solution x to the equation mx=y:" << endl << x << endl;
}
else
  cout << "The equation mx=y does not have any solution." << endl;


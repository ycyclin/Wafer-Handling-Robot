import math


def ik_r(position):
    x = position[0]
    y = position[1]
    z = position[2]
    l1 = 163
    l2 = 138
    l3 = 425
    l4 = 131
    l5 = 392
    l6 = 127
    l7 = 100
    l8 = 100
    theta1 = math.acos(-x/math.sqrt(x**2+(y+l8)**2)) - math.asin((l2-l4+l6)/math.sqrt(x**2+(y+l8)**2))
    theta5 = theta1
    l  = math.sqrt(x**2+(y+l8)**2-(l2-l4+l6)**2)
    lx = math.sqrt(l**2+(z+l7-l1)**2)
    print(math.acos((l3**2+l5**2-lx**2)/(2*l3*l5)))
    print((l3**2+l5**2-lx**2)/(2*l3*l5))
    print(l)
    theta3 = math.pi-math.acos((l3**2+l5**2-lx**2)/(2*l3*l5))
    theta2 = -math.acos((l3**2+lx**2-l5**2)/(2*l3*lx)) - math.asin((z+l7-l1)/lx)
    theta4 = -(theta2+theta3)
    theta6 = 0
    return [theta1, theta2, theta3, theta4, theta5, theta6]
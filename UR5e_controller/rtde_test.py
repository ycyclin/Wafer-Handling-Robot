import rtde_control
import math
import sys


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
    theta6 = 1*math.pi
    return [theta1, theta2, theta3, theta4, theta5, theta6]

rtde_c = rtde_control.RTDEControlInterface("169.254.228.2")

x = 1#int(sys.argv[1])

# Parameters
velocity = 0.0005
acceleration = 0.0005
dt = 1.0/500  # 2ms
lookahead_time = 0.1
gain = 300

# joint_q = ik_r([-186.5+x*10.0, -455, 390])
joint_q = ik_r([365, -455, 365])

# joint_q = ik_r([-187, -455, 390])
# joint_q = ik_r([-107, -455, 390])
# joint_q = ik_r([-7, -455, 390])
# joint_q = ik_r([182, -455, 360])
# joint_q = ik_r([282, -455, 365])
# joint_q = ik_r([363, -455, 365])
print(joint_q)
# Move to initial joint position with a regular moveJ
rtde_c.moveJ(joint_q)

# Execute 500Hz control loop for 2 seconds, each cycle is 2ms
for i in range(2000):
    t_start = rtde_c.initPeriod()
    rtde_c.servoJ(joint_q, velocity, acceleration, dt, lookahead_time, 100)
    rtde_c.waitPeriod(t_start)
rtde_c.servoStop()
rtde_c.stopScript()
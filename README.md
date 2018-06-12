# Multimodal
Multimodal Data Generation

Here, we adopted the Delaunay Triangulation (DT) as a technique to obtain high-resolution maps. DT generates a mesh from the projected sparse depth points on the camera coordinate system. The nearest neighbors were used to interpolate the unsampled locations of the map. The dense maps are obtained solely from LIDAR data thus, data (color or texture) from the camera is not used in the maps. Besides the depth map (DM), a dense reﬂectance map (RM) is also considered in the vehicle detection system. In the case of DM, the variable to be interpolated is the range (distance), while the reﬂectance value (reﬂection return) is the variable to be interpolated to generate the RM. The reﬂectivity attribute is related to the type of surface the LIDAR reﬂection is obtained.

An example of vehicle detection using the reflection intensity is described in the below.
Considering a 3D-LIDAR mounted on board a robotic vehicle, which is calibrated with respect to a monocular camera, a Dense Reflection Map (DRM) is generated from the projected sparse LIDAR’s reflectance intensity, and inputted to a Deep Convolutional Neural Network (ConvNet) object detection framework (YOLOv2) for the vehicle detection. Watch the result in the video below.

https://youtu.be/1JJHihvp7NE

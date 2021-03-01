# Multimodal Object Detection


![snip](https://github.com/alirezaasvadi/M2OD/blob/master/Screenshot%20from%202021-03-01%2013-21-37.png)
![snip](https://github.com/alirezaasvadi/M2OD/blob/master/Screenshot%20from%202021-03-01%2013-21-49.png)

The algorithm is described in:

A. Asvadi, L. Garrote, C. Premebida, P. Peixoto, U. Nunes, “Multimodal Vehicle Detection: Fusing 3D-LIDAR and Color Camera Data,” Pattern Recognition Letters, Elsevier, 2017. (In Press) DOI: 10.1016/j.patrec.2017.09.038

A. Asvadi, L. Garrote, C. Premebida, P. Peixoto, and U. Nunes, “DepthCN: Vehicle Detection Using 3D-LIDAR and ConvNet,” In Proceedings of IEEE 20th International Conference on Intelligent Transportation Systems (ITSC 2017), Yokohama, Japan. DOI: 10.1109/ITSC.2017.8317880

A. Asvadi, L. Garrote, C. Premebida, P. Peixoto, U. Nunes, “Real-Time Deep ConvNet-based Vehicle Detection Using 3D-LIDAR Reflection Intensity Data,” Robot 2017: Third Iberian Robotics Conference. Springer, 2017. (Book Chapter) DOI: 10.1007/978-3-319-70836-2_39

An example of vehicle detection using the reflection intensity is described in the below.
Considering a 3D-LIDAR mounted on board a robotic vehicle, which is calibrated with respect to a monocular camera, a Dense Reflection Map (DRM) is generated from the projected sparse LIDAR’s reflectance intensity, and inputted to a Deep Convolutional Neural Network (ConvNet) object detection framework (YOLOv2) for the vehicle detection. Watch the result in the video below.

https://youtu.be/1JJHihvp7NE

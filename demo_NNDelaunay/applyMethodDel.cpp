/*************************************************************************/
/* Upsampling from dense 3D LIDAR                                        */
/*                                                                       */
/* C.Premebida: June/2014                                                */
/* http://webmail.isr.uc.pt/~cpremebida/IROS14/LaserVisionFusion.html    */
/*                                                                       */
/*                                                                       */
/*                                                                       */
/*                                                                       */
/* All rights reserved.                                                  */
/*************************************************************************/



//Correr verticalmetne e analisar contexto.. vr como ter em conta altera??es (fundo carro)
//The Sobel operator, sometimes called the Sobel-Feldman operaator or Sobel filter, is used in image processing and computer vision, particularly within edge detection algorithms where it creates an image emphasising edges.
//Sobel operator - Wikipedia, the free encyclopedia

#include "mex.h"
#include <iostream>
#include <cmath>
#include "matrix.h"
#include <list>
#include <iostream>
#include <algorithm>
#include <vector>
#include "delaunay.h"
#include <omp.h>

//#if defined(__WIN32__) || defined(__WIN64__)

int roundr(double x)
{
    return x >= 0.0f ? floor(x + 0.5f) : ceil(x - 0.5f);
}
//#endif

class Point{
public:
        double x;
        double y;
        double z;
        double i;
        
        Point(){
            x=0;
            y=0;
            z=0;
            i=0;
        }
        
        Point(double x_,double y_,double z_,double i_){
            x=x_;
            y=y_;
            z=z_;
            i=i_;
        }
        
        
        bool xyEqual(const Point &pt)const {
            
            return (roundr(x*100.0)==roundr(pt.x*100.0)) && (roundr(y*100.0)==roundr(pt.y*100.0));
            
        }
        
        double distance(Point &a){
            return sqrt((x-a.x)*(x-a.x)+(y-a.y)*(y-a.y)+(z-a.z)*(z-a.z));
        }
        
        double distance2D(Point &a){
            return sqrt((x-a.x)*(x-a.x)+(y-a.y)*(y-a.y));
        }
        
//          bool operator() (Point &i,Point &j) const{
//              return (i.z<j.z);
//          }
//         bool operator< (Point &j) const {
//             return (z<j.z);
//         }
        
        static bool sorter (Point &g,Point &j)  {
            return (g.z<j.z);
        }
        std::string toString(){
        std::stringstream str;
        
        str<<"disp('"<<x<<" "<<y<<" "<<z<<" "<<i<<"');";
        
        return str.str();
        } 
        
};

 

double distance(double x0,double y0,double z0,double x1,double y1,double z1){
    return sqrt((x1-x0)*(x1-x0)+(y1-y0)*(y1-y0)+(z1-z0)*(z1-z0));
}

double distance(double x0,double y0,double x1,double y1){
    return sqrt((x1-x0)*(x1-x0)+(y1-y0)*(y1-y0));
}
/****************************/
/* The computational routine */
//sd number of points in pointcloud
void calc_Dense(double *x, double *y, double *dim, int sd)
{
    
 
   Delaunay<Point,Point> model;
 
    /*******************/
    
    
    model.reserve(sd);
    for (int k=0; k<sd; k=k+1){
        model.points.emplace_back((x[k+0*sd])-1.0,(x[k+1*sd]-(double)dim[0]),x[k+2*sd],x[k+3*sd]);    
    }

    
 
        model.triangulate();
 
    
#pragma omp parallel
{
    #pragma omp for schedule(static)
    for(int i=0;i<24;i++){
    model.mapEachTriangle(y,dim[1],i,24);
    }
}
    

    
    
} /*End "calc_Dense" Function*/
/****************************/
/****************************/
void mexFunction(
        int          nlhs,
        mxArray      *plhs[],
        int          nrhs,
        const mxArray *prhs[]
        )
{
    
    double  *Lidar;
    double  *par;
    const mwSize  *dims;
    double *Y;
    double *G;
    /* Check for proper number of arguments */
    if (nrhs != 2) {
        mexErrMsgIdAndTxt("MATLAB:mexcpp:nargin",
                "MEXCPP requires 2 input arguments.");
    } else if (nlhs > 2) {
        mexErrMsgIdAndTxt("MATLAB:mexcpp:nargout",
                "MEXCPP requires 2 output argument.");
    }
    
    Lidar   = mxGetPr(prhs[0]);
    par     = mxGetPr(prhs[1]);
    dims    = mxGetDimensions(prhs[0]);
    
    plhs[0]= mxCreateDoubleMatrix(par[1],par[2],mxREAL);
    Y =   mxGetPr(plhs[0]);
    
   // mexPrintf("dims %d %d---- %d , %d\n",sizeof(size_t),mxIsDouble(prhs[1]),dims[0],dims[1]);
   //mexPrintf("(%d) \tINPUT: %d  \t%d  \t%d  \t%d  \t%d  \t%f  \t%f \n",(int)par[7],(int)par[0],(int)par[1],(int)par[2],(int)par[3],(int)par[4],par[5],par[6]);
    
    
    //mexEvalString("disp('--------')");
        calc_Dense(Lidar,Y,par,(int)dims[0]);
   
   
   
   
    //mexEvalString("disp('--------')");
    
}

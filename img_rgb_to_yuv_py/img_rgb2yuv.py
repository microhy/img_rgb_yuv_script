# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a script file that read an image then
 make the color from RGB transform into YUV .
 
     ---- hymicro 2017-3-17
          https://github.com/microhy
          
"""

import skimage as skimg
from skimage import io,data,color
import numpy as np
#from scipy import linalg
import os


def RGB2YUV(rgb_matrix):
    ## reference Matlab rgb2ycbcr()
    ycbcr_from_rgb = np.array([[65.738, 129.057, 25.064],
                             [-37.945, -74.494, 112.439],
                             [112.439, -94.154, -18.285]]) 
    origOffset = np.array([16,128,128])
    scaleFactor = 256 
    ycbcr_from_rgb = ycbcr_from_rgb/scaleFactor
    
    img_height,img_width,img_dim = rgb_matrix.shape
    imgtmp = np.zeros(rgb_matrix.shape,dtype=np.float)
    
    for row in range(img_height):
        for col in range(img_width):
            imgtmp[row,col,:] = np.dot(ycbcr_from_rgb,rgb_matrix[row,col,:])
            imgtmp[row,col,:] = np.add(imgtmp[row,col,:],origOffset)       
    imgYUV = np.uint8(imgtmp)
    return imgYUV


def Get_YUV_Vector(yuv_matrix,yuv_format):  
    imgYUV = yuv_matrix
    img_height,img_width,img_dim = imgYUV.shape
    if yuv_format == '444':
        yuvlen = img_height*img_width*img_dim
        imgY = imgYUV[:,:,0]
        imgU = imgYUV[:,:,1]
        imgV = imgYUV[:,:,2]      
        
        imgyuv_vec = np.zeros([1,yuvlen],dtype=np.uint8)
        imgyuv_vec[0,0:imgYUV.size:3] = np.reshape(imgY,[1,np.size(imgY)])
        imgyuv_vec[0,1:imgYUV.size:3] = np.reshape(imgU,[1,np.size(imgU)])
        imgyuv_vec[0,2:imgYUV.size:3] = np.reshape(imgV,[1,np.size(imgV)])  
         
    elif yuv_format == '422yuyv':
        yuvlen = img_height*img_width + img_height*img_width/2 + img_height*img_width/2
        imgY = imgYUV[:,:,0]
        imgU = imgYUV[:,0:img_width:2,1]
        imgV = imgYUV[:,1:img_width:2,2] 
        
        imgyuv_vec = np.zeros([1,yuvlen],dtype=np.uint8)
        imgyuv_vec[0,0:imgYUV.size:2] = np.reshape(imgY,[1,np.size(imgY)])
        imgyuv_vec[0,1:imgYUV.size:4] = np.reshape(imgU,[1,np.size(imgU)])
        imgyuv_vec[0,3:imgYUV.size:4] = np.reshape(imgV,[1,np.size(imgV)])    
        
    elif yuv_format == '420yv12':
        yuvlen = img_height*img_width + img_height*img_width/4 + img_height*img_width/4
        imgY = imgYUV[:,:,0]
        imgU = imgYUV[0:img_height:2,0:img_width:2,1]
        imgV = imgYUV[1:img_height:2,0:img_width:2,2]    
        
        imgyuv_vec = np.zeros([1,yuvlen],dtype=np.uint8)
        imgY = np.reshape(imgY,[1,np.size(imgY)])
        imgU = np.reshape(imgU,[1,np.size(imgU)])
        imgV = np.reshape(imgV,[1,np.size(imgV)])  
        imgyuv_vec[0,0:imgY.size:1] = imgY
        imgyuv_vec[0,imgY.size:imgY.size+imgV.size:1] = imgV          
        imgyuv_vec[0,imgY.size+imgV.size:yuvlen:1] = imgU
              
    return imgyuv_vec



if __name__ == '__main__':
    imname = 'Penguins_720p.jpg' 
    imgrgb = skimg.io.imread(imname)
    skimg.io.imshow(imgrgb)
    
    imgyuv = RGB2YUV(imgrgb)
    skimg.io.imshow(imgyuv)
    
    yuvformat = '420yv12'
#    yuvformat = '422yuyv'
#    yuvformat = '444'
    imgyuv_vec = Get_YUV_Vector(imgyuv,yuvformat)
    
    yuvout_name = imname + '.' + yuvformat + '.yuv'
    fdout = open(yuvout_name,'wb')
    fdout.write(imgyuv_vec)
    fdout.close() 
    cmd = 'copy ' + yuvout_name + ' ' + 'yuv_disptemp.yuv'
    os.system(cmd)
    cmd = '7yuv yuv_disptemp.yuv'
    os.system(cmd)



from re import L
from unittest import result
import cv2
import numpy as np

def test():
    image_path = '/Users/abc/Desktop/Generative_Model_Implementation_Practice/datasets/celeba/img_align_celeba/000001.jpg'
    image = cv2.imread(image_path)
    image = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

    image3 = []
    for i in range(image.shape[0]):
        if i%2==0:
            image3.append(image[i])
    image3 = np.asarray(image3)
    print(image3.shape)
    m_v = cv2.vconcat([image, image3])
    #cv2.imshow('Result', m_v)

    #cv2.waitKey(0)
#if __name__ == '__main__':
def test_img():
    correct = []
    with open('img.dat') as f:
        for s in f:
            correct.append(s.split('\n')[0])
def main(image_path):
    
    image = cv2.imread(image_path)
    image = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

    image = cv2.resize(image, (32, 31), interpolation=cv2.INTER_AREA)
    result_img = edge_base(image)
    image2 = []
    for i in range(image.shape[0]):
        if i%2==0:
            image2.append(image[i])
    image2 = np.asarray(image2)
    # print(image2.shape)
    # cv2.imshow('Result', image2)
    # cv2.waitKey(0)
    return image2, result_img

def edge_base(img):
    interpolate_img = []
    for i in range(img.shape[0]):
        if i%2==0:
            interpolate_img.append(list(img[i]))
            
        else:
            interpolate_img.append([np.uint8(0)]*img.shape[1])
    interpolate_img=np.asarray(interpolate_img)
    # cv2.imshow('result',interpolate_img)
    # cv2.waitKey(0)
    for i in range(img.shape[0]):
        if i%2==0:
            pass
        else:
            for j in range(img.shape[1]):
                if (j==0 or j==31):
                    interpolate_img[i][j]=np.uint8((int(img[i-1][j])+int(img[i+1][j]))/2)
                else:
                    
                    D1 = abs(int(img[i-1][j-1])-int(img[i+1][j+1]))
                    D2 = abs(int(img[i-1][j])-int(img[i+1][j]))
                    D3 = abs(int(img[i-1][j+1])-int(img[i+1][j-1]))
                    mini = min(D1,D2,D3)
                    if D1==D2==D3==mini:
                        interpolate_img[i][j]=np.uint8((int(img[i-1][j])+int(img[i+1][j]))/2)
                    elif D1==D2==mini:
                        interpolate_img[i][j]=np.uint8((int(img[i-1][j])+int(img[i+1][j]))/2)
                    elif D1==D3==mini:
                        interpolate_img[i][j]=np.uint8((int(img[i-1][j-1])+int(img[i+1][j+1]))/2)
                    elif D2==D3==mini:
                        interpolate_img[i][j]=np.uint8((int(img[i-1][j])+int(img[i+1][j]))/2)
                    elif D1==mini:
                        interpolate_img[i][j]=np.uint8((int(img[i-1][j-1])+int(img[i+1][j+1]))/2)
                    elif D2==mini:
                        interpolate_img[i][j]=np.uint8((int(img[i-1][j])+int(img[i+1][j]))/2)
                    elif D3==mini:
                        interpolate_img[i][j]=np.uint8((int(img[i-1][j+1])+int(img[i+1][j-1]))/2)
        interpolate_img=np.asarray(interpolate_img)
        #print('here',interpolate_img.shape)
    # cv2.imshow('result',interpolate_img)
    # cv2.waitKey(0)
    return interpolate_img
                        
def int_to_hex(nr):
  h = format(int(nr), 'x')
  return '0' + h if len(h) % 2 else h


if __name__=='__main__':
    image_path = './image.jpg'
    image = cv2.imread(image_path)
    image = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

    image = cv2.resize(image, (32, 31), interpolation=cv2.INTER_AREA)
    img,result_img = main(image_path)
    img_data = []
    for i in range(img.shape[0]):
        for j in range(img.shape[1]): 
            img_data.append(int_to_hex(img[i][j]))

    #cv2.imwrite('interpolated.jpg',result_img)
    #print(result_img.shape)
    
    data = []
    for i in range(result_img.shape[0]):
        for j in range(result_img.shape[1]):
            
            data.append(int_to_hex(result_img[i][j]))

    print('check', len(data), len(img_data))
    print(data, img_data)
    with open('my_golden.dat','w') as f:
        for s in data:
            f.write(s+'\n')
    with open('my_img.dat','w') as f:
        for s in img_data:
            f.write(s+'\n')


    
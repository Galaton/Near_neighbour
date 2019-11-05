# healp to create a model sim test 

x1 = 10
x2 = 9
y1 = 2
y2 = 3

print(" -- x1=" +str(x1)+ ", x2="+str(x2)+", y1="+str(y1)+", y2="+str(y2)+
      "\n data_sg <= \""+format(y2,'08b').replace("-","1")+
      format(y1,'08b').replace("-","1")+
      format(x2,'08b').replace("-","1")+
      format(y2,'08b').replace("-","1")+
      "\";")


# near neigbour and min distance

min_distance = 10
min_neighbours = 1

print("-- min_distance="+str(min_distance)+"\n data_sg <= \""+
      format(min_distance,'032b').replace("-","1")+"\";")

print("-- min_neighbours="+str(min_neighbours)+"\n data_sg <= \""+
      format(min_neighbours,'032b').replace("-","1")+"\";")
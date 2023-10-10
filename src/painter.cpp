#include "painter.h"
#include <string>
#include <vector>
#include <sstream>
#include <QImage>
#include <QFile>
#include <QDebug>

using namespace std;

void Painter::save(QString filename,QString savename,QString imageEdit) {
	QImage data;
	QImage img;
	data.load("/home/ceres/Pictures/"+filename);
	if(imageEdit == "mirror"){
		img = data.mirrored(true, false);
	} else if(imageEdit == "grayscale") { 
		img = data.convertToFormat(QImage::Format_Grayscale8);
	}
	img.save("/home/ceres/Pictures/" + savename + ".jpg");
}


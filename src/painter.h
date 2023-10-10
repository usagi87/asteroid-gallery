#ifndef EXPORT_H
#define EXPORT_H

#include <QObject>


class Painter : public QObject
{	  
    Q_OBJECT
public:
	
	Q_INVOKABLE void save(QString filename,QString savename,QString imageEdit);

		
		
};

#endif

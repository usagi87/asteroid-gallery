/*
 * Copyright (C) 2020 Chandler Swift <chandler@chandlerswift.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import QtQuick 2.9
import org.asteroid.controls 1.0
import Qt.labs.folderlistmodel 2.1
import QtGraphicalEffects 1.15
import QtQuick.VirtualKeyboard 2.0
import QtQuick.VirtualKeyboard.Settings 2.15
import Painter 1.0
Application {
    id: app

    
	property var scaleVal : 1.0
	property var imageSaveName
	property var imageToEditSource
	property var imageFileName
	
    centerColor: "#31bee7"
    outerColor:  "#052442"
	
	function imageScale(){
		scaleVal = scaleVal + 0.5
		if(scaleVal > 4) scaleVal = 1.0;  
	}

Painter {
	id:painter
}

LayerStack {
   	id: layerStack
		firstPage: photoView
}

FolderListModel {
	id: folderModel
    folder: "file:///home/ceres/Pictures"
    nameFilters: ["*.jpg"]
    sortField: FolderListModel.Time
    sortReversed: false
    showDirs: false
}


Component{
	id:photoView
	Item{
		id:rootM		
    
    StatusPage {
        text: "No photos found"
        icon: "ios-images"
        visible: folderModel.count === 0
    }

	Item {
    	anchors.fill: parent

        Component {
            id: photoDelegate
            Item {
                width: app.width
                height: app.height

                Image {
                	anchors.verticalCenter:parent.verticalCenter
            		anchors.horizontalCenter:parent.horizontalCenter
            
                    source: fileURL
                    width: 300
                    height: 300
                    fillMode: Image.Image.Stretch
                }

                Label {
                    text: fileName
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: Dims.h(33)
                    font.pixelSize: Dims.l(6)
                    font.bold: true
                }

                IconButton {
                    iconName: "ios-brush-outline"
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        bottom: parent.bottom
                        bottomMargin: parent.height * 0.05
                    }
                    onClicked: { 
                    	imageToEditSource = fileURL
                    	imageFileName = fileName
                   		layerStack.push(imageViewer)				
                   	}
				}
			}
		}

        }

        ListView {
            id: lv
            anchors.fill: parent
            model: folderModel
            delegate: photoDelegate
            orientation: ListView.Horizontal
            snapMode: ListView.SnapToItem
            highlightRangeMode: ListView.StrictlyEnforceRange
        }

    }
}

Component{
	id:imageViewer
	Item{
		id:rootM
     	
     	Flickable {
			id: flickable1
        	anchors.horizontalCenter:parent.horizontalCenter
            anchors.verticalCenter:parent.verticalCenter
        	clip: true
        	height: 300
        	width: 300
        	contentWidth: 300 * scaleVal
        	contentHeight: 300 * scaleVal
        	Image {
            	id: imageToEdit
            	source: imageToEditSource // filled when we click the edit button
            	width: 300
            	height: 300
            	transformOrigin: Item.TopLeft
            	fillMode: Image.Image.Stretch
    			transform: Rotation { // This is just here as a UI demo; it won't actually edit an image.
                	id: imageToEditRotation
                	angle: 0
                	origin.x: imageToEdit.width/2
                	origin.y: imageToEdit.height/2
            	}
            	
            }
            		 
        }
        
        Flickable {
			id: flickable2
        	anchors.horizontalCenter:parent.horizontalCenter
            anchors.bottom : parent.bottom
            anchors.bottomMargin: parent.height * 0.05
        	flickableDirection:Flickable.HorizontalFlick
        	boundsBehavior :Flickable.DragAndOvershootBounds
        	clip: true
        	height: Dims.l(20)
        	width: 300
        	contentWidth: 400
        	contentHeight: Dims.l(20)
        	
        	Row{
        		spacing: 5
        		IconButton {
        			id: savebtn
        			width: Dims.l(18)
        			iconName: "ios-checkmark-circle-outline"
        			onClicked: layerStack.pop(rootM)
        		}
				IconButton {
        			id: rotateleftbtn
        			width: Dims.l(18)
        			iconName: "ios-refresh-circle-outline"
        			onClicked:{
        	   			imageToEditRotation.angle += 90
       				}
				}	
				IconButton {
           			id: expandbtn
           			width: Dims.l(18)
           			iconName: "ios-expand"
           			visible : true
           			onClicked:{ 
           				imageScale()
           				imageToEditRotation.origin.x = 300*scaleVal/2
        				imageToEditRotation.origin.y = 300*scaleVal/2
           				imageToEdit.scale = scaleVal
        			} 
       			}		
        		IconButton {
           			id: mirrorbtn
           			width: Dims.l(18)
           			iconName: "ios-swap"
           			visible : true
           			onClicked:{ 
           				layerStack.push(imageToMirrored)
           			} 
        		}
        		IconButton {
           			id: colorbtn
           			width: Dims.l(18)
           			iconName: "ios-swap"
           			visible : true
           			onClicked:{ 
						layerStack.push(imageColorEdit)							
           				 
           			} 
        		}
        		
        	}
        }
	}				
}

Component{
	id: imageColorEdit
	Item {
		id:rootM
		Image {
        	id: imageToEdit
        	anchors.verticalCenter:parent.verticalCenter
        	anchors.horizontalCenter:parent.horizontalCenter
            source: imageToEditSource // filled when we click the edit button
            width: 300
            height: 300
            smooth: true
        	visible: false
        }
        HueSaturation {
        	anchors.fill: imageToEdit
        	source: imageToEdit
        	hue: 0.0
        	saturation: -1.0
        	lightness: 0.0
    	}    
	
	IconButton{
			id:closebtn
			anchors.horizontalCenter:parent.horizontalCenter
			anchors.bottom :parent.bottom
			anchors.bottomMargin: parent.height * 0.05
			width: Dims.l(20)
        	iconName: "ios-close-circle-outline"
        	onClicked: layerStack.pop(rootM)
		}	
		IconButton {
    		id: savebtn
    		anchors.bottom:parent.bottom
			anchors.right:closebtn.left
			anchors.rightMargin:5
			anchors.bottomMargin: parent.height * 0.05
    	    width: Dims.l(20)
    	    iconName: "ios-checkmark-circle-outline"
    	    onClicked:{ 
				layerStack.push(imageToSave,{"imageEdit":"grayscale"})
				savebtn.visible=false            				 
    	    } 
   		}
	}
}

Component{
	id: imageToMirrored
	Item {
		id:rootM
		Image {
        	id: imageToEdit
        	anchors.verticalCenter:parent.verticalCenter
        	anchors.horizontalCenter:parent.horizontalCenter
            source: imageToEditSource // filled when we click the edit button
            width: 300
            height: 300
            smooth: true
        	mirror:true
        }    
	
		IconButton{
			id:closebtn
			anchors.horizontalCenter:parent.horizontalCenter
			anchors.bottom :parent.bottom
			anchors.bottomMargin: parent.height * 0.05
			width: Dims.l(20)
			iconName: "ios-close-circle-outline"
        	onClicked: layerStack.pop(rootM)
		}	
		IconButton {
    		id: savebtn
    		anchors.bottom:parent.bottom
			anchors.right:closebtn.left
			anchors.rightMargin:5
			anchors.bottomMargin: parent.height * 0.05
    	    width: Dims.l(20)
    	    iconName: "ios-checkmark-circle-outline"
    	    onClicked:{ 
				layerStack.push(imageToSave,{"imageEdit":"mirror"})
				savebtn.visible=false 
			} 
   		}
	}	
}


Component {
	id:imageToSave	
	Item {
		id:rootM
		property alias inputMethodHints: txtField.inputMethodHints
		property var pop
		property var imageEdit
					
		TextField {
    		id: txtField
    		anchors.top:parent.top
    		anchors.topMargin :parent.height * 0.1
    		anchors.horizontalCenter:parent.horizontalCenter
    	    width: Dims.w(80)
    	    previewText: qsTrId("")
   		}	
	
		InputPanel {
    		id: kbd
    	   	anchors {
   		    	verticalCenter: parent.verticalCenter
   		    	horizontalCenter: parent.horizontalCenter
   			}
   			width:parent.width * 0.90 //Dims.w(95)
    	   	visible: active
   		}
		IconButton {
			id:txtEnter
			anchors.bottom : parent.bottom
 			anchors.horizontalCenter : parent.horizontalCenter		
 			iconName: "ios-checkmark-circle-outline"
 			onClicked: {
				painter.save(imageFileName,txtField.text,imageEdit)	
				layerStack.pop(rootM)				
			}
		}
		Component.onCompleted: {
		VirtualKeyboardSettings.styleName = "watch"
		
   		}
	}		
}

}


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

Application {
    id: app

    property var inEditMode: false
	property var scaleVal : 1.0
	
    centerColor: folderModel.count > 0 ? "#31bee7" : "#31bee7"
    outerColor:  folderModel.count > 0 ? "#052442": "#052442"
	
	function imageScale(){
		scaleVal = scaleVal + 0.5
		if(scaleVal > 4) scaleVal = 1.0;  
	}
	
    FolderListModel {
        id: folderModel
        folder: "file:///home/ceres/Pictures"
        nameFilters: ["*.jpg"]
        sortField: FolderListModel.Time
        sortReversed: false
        showDirs: false
    }

    StatusPage {
        text: "No photos found"
        icon: "ios-images"
        visible: !inEditMode && folderModel.count === 0
    }

    function edit(imagePath) {
        inEditMode = true
        imageToEdit.source = imagePath
    }

    Item {
        anchors.fill: parent

        visible: !inEditMode && folderModel.count > 0

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
                    onClicked: edit(fileURL)
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
            onCurrentIndexChanged: inEditMode = false
        }

    }

    Item {
        // TODO: add to LayerStack
        anchors.fill: parent
        visible: inEditMode
        	
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
            	source: "" // filled when we click the edit button
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

        IconButton {
            id: savebtn
            anchors.horizontalCenter:parent.horizontalCenter
            anchors.bottom:parent.bottom
            iconName: "ios-checkmark-circle-outline"
            onClicked: inEditMode = false
        }

        IconButton {
            id: rotateleftbtn
            anchors.verticalCenter:parent.verticalCenter
            anchors.left:parent.left
            iconName: "ios-refresh-circle-outline"
            onClicked: imageToEditRotation.angle += 90
        }

		IconButton {
            id: expandbtn
            anchors.verticalCenter:parent.verticalCenter
            anchors.right:parent.right
            iconName: "ios-expand"
            visible : true
            onClicked:{ 
            	imageScale()
            	imageToEdit.scale = scaleVal
            } 
        }
    }
}

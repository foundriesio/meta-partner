# Qualcomm FoundriesFactory Reference Manual

## Table of Contents

- [Document Revision History](#document-revision-history)
- [Definitions, Acronyms, and Abbreviations](#definitions-acronyms-and-abbreviations)
- [Getting Started](#getting-started)
  - [Qualcomm® Robotics RB3G2 Development Kit](#qualcomm-robotics-rb3g2-development-kit)
  - [Serial Console](#serial-console)
  - [Connect via WiFi](#connect-via-wifi)
  - [Enabling Ethernet and USB](#enabling-ethernet-and-usb)
  - [SSH](#ssh)
  - [Register your device](#register-your-device)
- [Developer Workflows](#developer-workflows)
  - [Git Repositories](git-repositories)
- [Compose-Apps](#compose-apps)
  - [AIHub](#qualcomm-ai-hub)
  - [shellhttpd](#shellhttpd)
  - [qimsdk-lmp](#qimsdk-lmp)
  - [gst-concurrent-videoplay-composition](#qimsdk-lmp)
  - [gst-ai-classification](#gst-ai-classification)
  - [gst-ai-daisychain-detection-classification](#gst-ai-daisychain-detection-classification)
  - [gst-ai-monodepth](#gst-ai-monodepth)
  - [gst-ai-object-detection](#gst-ai-object-detection)
  - [gst-ai-parallel-inference](#gst-ai-parallel-inference)
  - [gst-ai-pose-detection](#gst-ai-pose-detection)
  - [gst-ai-segmentation](#gst-ai-segmentation)
  - [gst-multi-camera-example](#gst-multi-camera-example)
  - [Deploy](#deploy)
- [Fioctl](#fioctl)
  - [View Targets](#view-targets)
  - [View Devices](#view-devices)
  - [Change Device Tag](#view-devices)
  - [Change Device Application](#change-device-application)
  - [Deploy shellhttpd Application](#deploy-shellhttpd-application)
  - [Deploy gst-concurrent-videoplay-composition Application](#deploy-gst-concurrent-videoplay-composition-application)
  - [Deploy gst-ai-classification Application](#deploy-gst-ai-classification-application)
  - [Deploy gst-ai-daisychain-detection-classification Application](#deploy-gst-ai-daisychain-detection-classification-application)
  - [Deploy gst-ai-monodepth Application](#deploy-gst-ai-monodepth-application)
  - [Deploy gst-ai-object-detection Application](#deploy-gst-ai-object-detection-application)
  - [Deploy gst-ai-parallel-inference Application](#deploy-gst-ai-parallel-inference-application)
  - [Deploy gst-ai-pose-detection Application](#deploy-gst-ai-pose-detection-application)
  - [Deploy gst-ai-segmentation Application](#deploy-gst-ai-segmentation-application)
  - [Deploy gst-multi-camera-example Application](#deploy-gst-multi-camera-example-application)
  - [Enable/Disable Wireguard VPN](#enabledisable-wireguard-vpn)
- [FoundriesFactory Images](#foundriesfactory-images)
  - [LmP Factory Image](#lmp-factory-image)
- [Wireguard VPN](#wireguard-vpn)
- [Updating FoundriesFactory Images](#updating-foundriesfactory-images)
- [Useful Links](#updating-foundriesfactory-images)

## Document Revision History

| Version | Date       | Comments        |
|---------|------------|-----------------|
| v0.1    | 2024-07-01 | Initial release |

## Definitions, Acronyms, and Abbreviations

| Variable        | Meaning                                                           |
|-----------------|-------------------------------------------------------------------|
| `<factory>`     | Your Factory name                                                 |
| `<device_name>` | Device name used when you registered the device                   |
| `<app_name>`    | Docker-compose app available to run on the device                 |
| `<tag_name>`    | The branch you want your device to follow                         |
| `<IP>`          | Device IP                                                         |

## Getting Started

To get started using the FoundriesFactory™ Platform and the Linux microPlatform, please follow the steps below:

1. To start a new Factory, please visit https://app.foundries.io/ and sign up for an account.
2. In the Platform drop down, select Qualcomm RB3 Gen 2 Development Kit.
3. Give your Factory a name, and click "Create Factory".
4. The Factory owners may invite additional users to their FoundriesFactory Account via email under the "Members" tab of the Factory interface.
    - Manage your Factory users: ```https://app.foundries.io/factories/<factory>/members/```
5. Fioctl CLI Installation: https://docs.foundries.io/latest/getting-started/install-fioctl/index.html
6. Configure git using Fioctl: https://docs.foundries.io/latest/getting-started/git-config/index.html

**Note**: On macOS, you may encounter authentication issues due to Git on OSX using the Keychain Access Utility. The solution is to remove Keychain Access entries from your git config file.


### Qualcomm® Robotics RB3G2 Development Kit

Once your Factory has been created, it will build the source code for the RB3G2 and produce a Target. A Target is a secure over-the-air update but also provides the build artifacts for initial provisioning.

1. Download the image: ```https://app.foundries.io/factories/<factory>/targets/1/artifacts/qcm6490/lmp-factory-image-qcm6490.qcomflash.tar.gz```
2. Extract the `tar.gz` into a known location.
3. Open a terminal and change the directory into `lmp-factory-image-qcm6490`.
4. The compressed archive contains the flashing tool “qdl”.
   - Note: The tool from the build has the interpreter set incorrectly.
5. Download and compile qdl for your platform:
   - `git clone https://github.com/linux-msm/qdl`
   - Read the README and install build dependencies
   - `cd qdl`
   - `make`
6. Disable ModemManager on some host systems if necessary.

Now configure the Qualcomm® Robotics RB3G2 Development Kit:

1. Set up DIP_SW_0 positions 1 and 2 to ON. This enables serial output to the debug port.
2. Connect the USB debug cable to the host. Baud rate is 115200.
   - You can use your favorite UART client to access the console, such as minicom, putty etc.
3. The serial connection is based on the FTDI chip:
   - `/dev/serial/by-id/usb-FTDI_FT230X_Basic_UART_<serial ID>-if00-port0`
4. Plug in the USB-C cable from the host.
5. Run the command to flash:
   - `./qdl --debug prog_firehose_ddr.elf rawprogram*.xml patch*.xml`
6. Press and hold the F_DL button and connect the power cable.


### Serial Console

After flashing, the device should boot the Linux microPlatform properly. Use your serial console to log in.

Username: `fio`
Password: `fio`


### Connect via WiFi

Using the WiFi radio, connect it to the internet using NetworkManager CLI:

```
sudo nmcli device wifi connect “<AP Name>” password “<AP password>”
```

The sudo password is `fio`.

### Enabling Ethernet and USB

In order to enable Ethernet, you must provide firmware in the Yocto recipe below. This is a one time operation, which will also enable USB type A ports to function

Register and log in to https://www.renesas.com, then download firmware from
https://www.renesas.com/us/en/products/interface/usb-switches-hubs/upd720201-usb-30-host-controller.

Once downloaded, copy USB3-201-202-FW-20131112.zip at recipes-firmware/firmware/renesas-upd720201
and add the renesas-upd720201 package to your image.

#### Add downloaded firmware zip to the correct layer location

```bash
git clone https://source.foundries.io/factories/<factory>/meta-subscriber-overrides.git
cd meta-subscriber-overrides
mkdir -p recipes-firmware/firmware/renesas-upd720201
cp /tmp/USB3-201-202-FW-20131112.zip recipes-firmware/firmware/renesas-upd720201
echo 'FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"' > recipes-firmware/firmware/renesas-upd720201_20131112.bbappend
echo 'SRC_URI += "file://USB3-201-202-FW-20131112.zip"' >> recipes-firmware/firmware/renesas-upd720201_20131112.bbappend
```

#### Add renesas-upd720201 to lmp-factory-image

```bash
echo 'CORE_IMAGE_BASE_INSTALL += "renesas-upd720201"' >> recipes-samples/images/lmp-factory-image.bb
```

#### Commit and push to create a new build
```bash
git add .
git commit -s -m "renesas-upd720201: add firmware file"
git push
```

After you push, the FoundriesFactory will build a new target. Once built, any registered device will update over the air.


### SSH

Once connected to the network you can log in over ssh if desired:

```bash
ssh fio@qcm6490.local
```

OR

```bash
ssh fio@<IP>
```

Password: `fio`

---

### Register Your Device

Register your device with FoundriesFactory:
`https://docs.foundries.io/latest/getting-started/register-device/index.html`

---

## Developer Workflows

FoundriesFactory produces targets, which are references to platform images and docker applications.

Your FoundriesFactory source code can be found here:
- `https://source.foundries.io/factories/<factory>/`

The built targets can be found here:
- `https://app.foundries.io/factories/<factory>/targets/`

### Git Repositories:

1. `ci-scripts.git`: Configures your factory branches - `factory-config.yml`
2. `containers.git`: Contains the source code for your Docker applications
3. `lmp-manifest.git`: Yocto manifest for your platform build
4. `meta-subscriber-overrides.git`: Yocto layer which overrides the Foundries.io Linux microPlatform

---

## Compose-Apps

Compose apps fill the gap for Factory devices in distributing applications.

- To build your own compose applications, refer to `https://docs.foundries.io/latest/reference-manual/docker/compose-apps.html`
- Your factory has some sample compose applications ready to deploy.

### Qualcomm® AI Hub

[Qualcomm® AI Hub](https://aihub.qualcomm.com/get-started) simplifies deploying AI models for vision, audio, and speech applications to edge devices. You can optimize, validate, and deploy your own AI models on hosted Qualcomm platform devices within minutes.

Please see our [Getting Started](#getting-started) guide to start using a factory with AIHub.

The applications below which have a prefix of `gst-ai` use the models from [AIHub](https://aihub.qualcomm.com) and have been packaged into the `qimsdk-lmp` image in your Factory.

- If you are curious how this process works, refer to `https://source.foundries.io/<factory>/containers.git/tree/qimsdk-lmp/Dockerfile`
- Should you want to add or replace a model from [AIHub](https://aihub.qualcomm.com) you may modify the `qimsdk-lmp` Dockerfile and add a `RUN` command to download file into `/src/models/` inside the container.
  - During runtime, the models will be placed in `/opt` and can be referenced in the compose command to instruct the application to use a specific model.
  - Please review the `gst-ai-classification` `docker-compose.yml` in `https://source.foundries.io/<factory>/containers.git` as an example of how to run a different model.

### shellhttpd

This is a simple httpd server, built from a Dockerfile in the factory source code. Enable the shellhttpd compose app before deployment:

```bash
git clone https://source.foundries.io/factories/<factory>/containers.git
git mv shellhttpd.disabled shellhttpd
git commit -s -m “enable shellhttp” && git push
```

This compose-app does not require any hardware other than a network connection.

### qimsdk-lmp

This is a development container for the gstreamer applications listed below. It provides the assembled binaries, models, and video files for the applications to consume. If you want to build your own gstreamer pipeline application, this would be the place to start.

For more information, please see the project's [README](https://github.com/foundriesio/qimsdk-lmp/blob/main/README.md).

### gst-concurrent-videoplay-composition

The gst-concurrent-videoplay-composition command-line application facilitates concurrent video decode and playback for advanced video coding (AVC)-coded videos and performs composition on a display for video wall application. The application requires at least one input video file, which is expected to be an MP4 file with the AVC codec.

For a more detailed description please see [Qualcomm Linux Sample Apps](https://docs.qualcomm.com/bundle/publicresource/topics/80-70014-50/gst-concurrent-videoplay-composition.html?product=1601111740013072&facet=Qualcomm%20Intelligent%20Multimedia%20SDK).

Enable the gst-concurrent-videoplay-composition compose app before deployment:

```bash
git clone https://source.foundries.io/factories/<factory>/containers.git
git mv gst-concurrent-videoplay-composition.disabled gst-concurrent-videoplay-composition
git commit -s -m “gst-concurrent-videoplay-composition” && git push
```

This compose-app requires a connected display to function properly.

### gst-ai-classification

The gst-ai-classification application enables subject recognition in the image. The use cases uses the Qualcomm Neural Processing SDK runtime or the TensorFlow Lite (TFLite) runtime. The compose file provides you will a few commands you can comment/uncomment to use different models for classification.

For a more detailed description please see [Qualcomm Linux Sample Apps](https://docs.qualcomm.com/bundle/publicresource/topics/80-70014-50/gst-ai-classification.html?product=1601111740013072&facet=Qualcomm%20Intelligent%20Multimedia%20SDK).

Enable the gst-ai-classification compose app before deployment:

```bash
git clone https://source.foundries.io/factories/<factory>/containers.git
git mv gst-ai-classification.disabled gst-ai-classification
git commit -s -m “gst-ai-classification” && git push
```

This compose-app requires a connected display and the camera mezzanine to function properly.

### gst-ai-daisychain-detection-classification

The gst-ai-daisychain-detection-classification application enables you to perform cascaded object detection and classification with a camera and a file source. The use case involves detecting objects and classifying the detected objects.

For a more detailed description please see [Qualcomm Linux Sample Apps](https://docs.qualcomm.com/bundle/publicresource/topics/80-70014-50/daisy-chain-detection-and-classification.html?product=1601111740013072&facet=Qualcomm%20Intelligent%20Multimedia%20SDK).

Enable the gst-ai-daisychain-detection-classification compose app before deployment:

```bash
git clone https://source.foundries.io/factories/<factory>/containers.git
git mv gst-ai-daisychain-detection-classification.disabled gst-ai-daisychain-detection-classification
git commit -s -m “gst-ai-daisychain-detection-classification” && git push
```

This compose-app requires a connected display and the camera mezzanine to function properly.

### gst-ai-monodepth

The gst-ai-monodepth application enables you to infer depth from a live camera stream.

For a more detailed description please see [Qualcomm Linux Sample Apps](https://docs.qualcomm.com/bundle/publicresource/topics/80-70014-50/mono-depth-from-video.html?product=1601111740013072&facet=Qualcomm%20Intelligent%20Multimedia%20SDK).

Enable the gst-ai-monodepth compose app before deployment:

```bash
git clone https://source.foundries.io/factories/<factory>/containers.git
git mv gst-ai-monodepth.disabled gst-ai-monodepth
git commit -s -m “gst-ai-monodepth” && git push
```

This compose-app requires a connected display and the camera mezzanine to function properly.

### gst-ai-object-detection

The gst-ai-object-detection application enables you to detect objects within images and videos. The use cases demonstrate the execution of YOLOv5, YOLOv8, and YOLO-NAS using the Qualcomm Neural Processing SDK runtime.

For a more detailed description please see [Qualcomm Linux Sample Apps](https://docs.qualcomm.com/bundle/publicresource/topics/80-70014-50/gst-ai-object-detection.html?product=1601111740013072&facet=Qualcomm%20Intelligent%20Multimedia%20SDK).

Enable the gst-ai-object-detection compose app before deployment:

```bash
git clone https://source.foundries.io/factories/<factory>/containers.git
git mv gst-ai-object-detection.disabled gst-ai-object-detection
git commit -s -m “gst-ai-object-detection” && git push
```

This compose-app requires a connected display and the camera mezzanine to function properly.

### gst-ai-parallel-inference

The gst-ai-parallel-inference application enables you to perform object detection, object classification, pose detection, and image segmentation on a live camera stream. The use cases uses the Qualcomm Neural Processing SDK runtime for object detection and image segmentation, and the TFLite runtime for classification and pose detection.

For a more detailed description please see [Qualcomm Linux Sample Apps](https://docs.qualcomm.com/bundle/publicresource/topics/80-70014-50/gst-ai-parallel-inference.html?product=1601111740013072&facet=Qualcomm%20Intelligent%20Multimedia%20SDK).

Enable the gst-ai-parallel-inference compose app before deployment:

```bash
git clone https://source.foundries.io/factories/<factory>/containers.git
git mv gst-ai-parallel-inference.disabled gst-ai-parallel-inference
git commit -s -m “gst-ai-parallel-inference” && git push
```

This compose-app requires a connected display and the camera mezzanine to function properly.

### gst-ai-pose-detection

The gst-ai-pose-detection application enables you to detect the body pose of the subject in an image or video. The use cases use a video stream from a camera, leverages TFLite for pose detection, and displays the results on the screen.

For a more detailed description please see [Qualcomm Linux Sample Apps](https://docs.qualcomm.com/bundle/publicresource/topics/80-70014-50/gst-ai-pose-detection.html?product=1601111740013072&facet=Qualcomm%20Intelligent%20Multimedia%20SDK).

Enable the gst-ai-pose-detection compose app before deployment:

```bash
git clone https://source.foundries.io/factories/<factory>/containers.git
git mv gst-ai-pose-detection.disabled gst-ai-pose-detection
git commit -s -m “gst-ai-pose-detection” && git push
```

This compose-app requires a connected display and the camera mezzanine to function properly.

### gst-ai-segmentation

The gst-ai-segmentation application enables you to divide an image into meaningful parts or segments and assign a label to each homogenous segment based on similarity of the attributes.
The application shows how to use both the Qualcomm Neural Processing SDK runtime and TFLite runtime for image segmentation.

For a more detailed description please see [Qualcomm Linux Sample Apps](https://docs.qualcomm.com/bundle/publicresource/topics/80-70014-50/gst-ai-segmentation.html?product=1601111740013072&facet=Qualcomm%20Intelligent%20Multimedia%20SDK).

Enable the gst-ai-segmentation compose app before deployment:

```bash
git clone https://source.foundries.io/factories/<factory>/containers.git
git mv gst-ai-segmentation.disabled gst-ai-segmentation
git commit -s -m “gst-ai-segmentation” && git push
```

This compose-app requires a connected display and the camera mezzanine to function properly.

### gst-multi-camera-example

The gst-multi-camera-example application enables you to simultaneously stream from two camera sensors on the device. It composes camera feeds side-by-side to display on a screen, or encodes and stores the video streams to file. Typical use cases that need multiple camera inputs are dash camera or stereo camera, which can use this application as a reference to build a use case.

For a more detailed description please see [Qualcomm Linux Sample Apps](https://docs.qualcomm.com/bundle/publicresource/topics/80-70014-50/gst-multi-camera-stream-example.html?product=1601111740013072&facet=Qualcomm%20Intelligent%20Multimedia%20SDK).

Enable the gst-multi-camera-example compose app before deployment:

```bash
git clone https://source.foundries.io/factories/<factory>/containers.git
git mv gst-multi-camera-example.disabled gst-multi-camera-example
git commit -s -m “gst-multi-camera-example” && git push
```

This compose-app requires a connected display and the camera mezzanine to function properly.

### Deploy

After you push, the FoundriesFactory will build a new target. Afterwards, deploy as described below.


## Fioctl

Fioctl is a command-line tool to manage your Factory. To deploy applications listed below, you must have enabled them first as described above. The polling time on devices by default is five minutes, once you have issued your deployment command, please wait up to five minutes to see the change reflected.

### Examples:

#### View Targets:

  ```bash
  ./fioctl targets list -f <factory>
  ```
#### View Devices:

  ```bash
  ./fioctl devices list -f <factory>
  ```
#### Change Device Tag:

  ```bash
  ./fioctl devices -f <factory> config updates <device_name> --tags <tag_name>
  ```
#### Change Device Application:

  ```bash
  ./fioctl devices -f <factory> config updates <device_name> --apps <app_name1>,<app_name2>,<app_name3>
  ```
#### Deploy shellhttpd Application:

  ```bash
  ./fioctl devices -f <factory> config updates <device_name> --apps shellhttpd
  ```
#### Deploy gst-concurrent-videoplay-composition Application:

  ```bash
  ./fioctl devices -f <factory> config updates <device_name> --apps gst-concurrent-videoplay-composition
  ```
#### Deploy gst-ai-classification Application:

  ```bash
  ./fioctl devices -f <factory> config updates <device_name> --apps gst-ai-classification
  ```
#### Deploy gst-ai-daisychain-detection-classification Application:

  ```bash
  ./fioctl devices -f <factory> config updates <device_name> --apps gst-ai-daisychain-detection-classification
  ```
#### Deploy gst-ai-monodepth Application:

  ```bash
  ./fioctl devices -f <factory> config updates <device_name> --apps gst-ai-monodepth
  ```
#### Deploy gst-ai-object-detection Application:

  ```bash
  ./fioctl devices -f <factory> config updates <device_name> --apps gst-ai-object-detection
  ```
#### Deploy gst-ai-parallel-inference Application:

  ```bash
  ./fioctl devices -f <factory> config updates <device_name> --apps gst-ai-object-detection
  ```
#### Deploy gst-ai-pose-detection Application:

  ```bash
  ./fioctl devices -f <factory> config updates <device_name> --apps gst-ai-pose-detection
  ```
#### Deploy gst-ai-segmentation Application:

  ```bash
  ./fioctl devices -f <factory> config updates <device_name> --apps gst-ai-segmentation
  ```
#### Deploy gst-multi-camera-example Application:

  ```bash
  ./fioctl devices -f <factory> config updates <device_name> --apps gst-multi-camera-example
  ```
#### Enable/Disable Wireguard VPN:

  ```bash
  ./fioctl devices -f <factory> config wireguard <device_name> enable/disable
  ```

---

## FoundriesFactory Images

### LmP Factory Image

This image configuration includes all the required packages to be baked into the final image:
- `https://source.foundries.io/factories/<factory>/meta-subscriber-overrides.git/tree/recipes-samples/images/lmp-factory-image.bb?h=main`

---

## Wireguard VPN

Registered devices can form a VPN to allow remote access even behind firewalls:
- `https://docs.foundries.io/latest/reference-manual/remote-access/wireguard.html`

---

## Updating FoundriesFactory Images

To update your Factory, follow these steps:
`https://docs.foundries.io/latest/reference-manual/linux/linux-update.html`

---

## Useful Links

- `https://docs.foundries.io/latest/user-guide/lmp-customization/linux-extending.html`
- `https://docs.foundries.io/latest/reference-manual/factory/sboms.html`
- `https://docs.foundries.io/latest/user-guide/containers-and-docker/containers.html`

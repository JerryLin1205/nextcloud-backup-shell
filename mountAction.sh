#!/bin/bash
function mountPartition(){
    #uuid=0d5ae66f-c33f-4e18-8b4e-c9f80735e3b7
    uuid=$1
    expectedmp=$2
    echo "Expected mount point:" $2
    mountpoint=$(lsblk -o UUID,MOUNTPOINT | awk -v u="$uuid" '$1 == u {print $2}')
    devpath=$(lsblk -o UUID,PATH | awk -v u="$uuid" '$1 == u {print $2}')
    echo 'mountpoint:' $mountpoint
    if [ $mountpoint ]; then
    # Mounted, check the mountpoint is expected or not
        if [ "$mountpoint" = "$expectedmp" ]; then
            # Mounted, check if it's in RO/RW mode mode
            echo 'Mounted as expected, check mount mode'
            if [ ! -w $mountpoint ]; then    #Not writable, remount it as RW
                echo "Not writable, remount it as RW"
                sudo mount -o rw,remount $devpath $expectedmp
            fi
        else
            # Mounted, but mountpointed is not expected
            echo "Start to umount from $devpath"
            sudo umount $devpath
            echo "Start to mount $devpath -> $expectedmp"
            sudo mount $devpath $expectedmp
        fi
    else
        echo "Start to mount $devpath -> $expectedmp"
        sudo mount $devpath $expectedmp    
    fi    
}

function mountToReadOnly(){
    uuid=$1
    echo "----Mount to read-only, device uuid: $uuid"
    devpath=$(lsblk -o UUID,PATH | awk -v u="$uuid" '$1 == u {print $2}')
    echo "----Device path:$devpath"
    if [ -n $devpath ]; then
        echo "Mount $devpath to readonly "
        sudo mount -o ro,remount $devpath
    else
        echo "No devices found, no re-mount action performed"
    fi
}
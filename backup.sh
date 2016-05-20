function backup() {
    DIR=$1
    DEST=$2
    if [ ! -d $DIR ]
    then
        echo "Directory to backup doesn't exists: $DIR"
        exit 1
    fi
    if [ ! -d $DEST ]
    then
        echo "Backup destination doesn't exists: $DEST"
        exit 1
    fi
    CURRENT_BAK=$DIR.current
    DEST_CURRENT_BAK=$DEST/$CURRENT_BAK
    if [ ! -L $DEST_CURRENT_BAK ]
    then
        echo "Current backup symlink doesn't exist: $DEST_CURRENT_BAK"
        exit 1
    fi
    if [ ! -e $DEST_CURRENT_BAK ]
    then
        echo "Current backup symlink is broken: $DEST_CURRENT_BAK"
        exit 1
    fi

    TIMED_BAK_DIR=$DIR.`date "+%Y%m%d_%H%M"`
    DEST_TIMED_BAK_DIR=$DEST/$TIMED_BAK_DIR
    if [ -e $DEST_TIMED_BAK_DIR ] 
    then
        echo "Timed backup directory already exists: $DEST_TIMED_BAK_DIR"
        exit 1
    fi

    if ! rsync -a --link-dest=$DEST_CURRENT_BAK $DIR/ $DEST_TIMED_BAK_DIR/
    then
        echo "rsync failed"
        exit 2
    fi
    rm $DEST_CURRENT_BAK
    if ! create_link $DEST $TIMED_BAK_DIR $CURRENT_BAK
    then
        echo "Failed to create current symlink: $CURRENT_BAK -> $TIMED_BAK_DIR in $DEST"
        exit 1
    fi
}

function create_link {
    DEST=$1
    SOURCE=$2
    TARGET=$3

    pushd $DEST
    if [ -e $TARGET ]
    then
        echo "Target $TARGET already exists in $DEST"
        popd
        return 1
    fi
    if ! ln -s $SOURCE $TARGET
    then
        popd
        return 1
    fi
    popd
}
    
function backup_all {
    DEST=/Volumes/MacExtraDrive/mac.bak
    backup safeplace $DEST
    backup 3rdparty $DEST
}

backup_all

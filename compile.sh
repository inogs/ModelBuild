rm -r OGSTM_BUILD*
bash builder_ogstm_bfm.sh
cd ../wrkdir/MODEL/
ln -sf ../../CODE/OGSTM_BUILD*/ogstm.xx ogstm.xx

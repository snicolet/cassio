UNIT MyFileIDs;

INTERFACE







 uses
     UnitDefCassio , Files;

	function CreateFileID(var spec : FSSpec; var id : SInt32) : OSErr;
	function ResolveFileID(vrn: SInt16; id : SInt32; var spec : FSSpec) : OSErr;

IMPLEMENTATION







	uses
		MacErrors,
		MyMemory,
		MyFileSystemUtils;

	function CreateFileID(var spec : FSSpec; var id : SInt32) : OSErr;
		var
			err : OSErr;
			pb : HParamBlockRec;
	begin
		MZero(@pb, SizeOf(pb));
		pb.iovRefNum := spec.vRefNum;
		pb.ioSrcDirID := spec.parID;
		pb.ioNamePtr := @spec.name;
		err := PBCreateFileIDRefSync(@pb);
		if (err = fidExists) then begin
			err := noErr;
		end;
		id := pb.ioFileID;
		CreateFileID := err;
	end;

	function ResolveFileID(vrn: SInt16; id : SInt32; var spec : FSSpec) : OSErr;
		var
			err : OSErr;
			pb : HParamBlockRec;
	begin
		MZero(@pb, SizeOf(pb));
		pb.iovRefNum := vrn;
		pb.ioFileID := id;

		SetNameOfFSSpec(spec, '');

		pb.ioNamePtr := @spec.name;
		err := PBResolveFileIDRefSync(@pb);
		spec.vRefNum := pb.iovRefNum;
		spec.parID := pb.ioSrcDirID;
		ResolveFileID := err;
	end;

end.

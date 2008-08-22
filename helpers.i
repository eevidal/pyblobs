
// Karl special:
%{
#define SWIG_exception(code, msg) SWIG_Error(code, msg);
%}


// ======================================================

/* Python doesn't know what to do with these */
%rename (asIplImage) operator IplImage*;
%rename (asCvMat) operator CvMat*;
%ignore operator const IplImage*;
%ignore operator const CvMat*;


// ======================================================

/****************************************************************************************\
*          Array allocation, deallocation, initialization and access to elements         *
\****************************************************************************************/

%nodefault _IplImage;
%newobject cvCreateImage;
%newobject cvCreateImageMat;
%newobject cvCreateImageHeader;
%newobject cvCloneImage;
%newobject cvCloneImageMat;

%nodefault CvMat;
%newobject cvCreateMat;
%newobject cvCreateMatHeader;
%newobject cvCloneMat;
%newobject cvGetSubRect;
%newobject cvGetRow;
%newobject cvGetRows;
%newobject cvGetCol;
%newobject cvGetCols;
%newobject cvGetDiag;




/// This hides all members of the IplImage which OpenCV doesn't use.
%ignore _IplImage::nSize;
%ignore _IplImage::alphaChannel;
%ignore _IplImage::colorModel;
%ignore _IplImage::channelSeq;
%ignore _IplImage::maskROI;
%ignore _IplImage::imageId;
%ignore _IplImage::tileInfo;
%ignore _IplImage::BorderMode;
%ignore _IplImage::BorderConst;
%ignore _IplImage::imageDataOrigin;

/**
 * imageData is hidden because the accessors produced by SWIG are not 
 * working correct. Use imageData_set and imageData_get instead 
 * (they are defined in "imagedata.i")
 */
%ignore _IplImage::imageData;


// ======================================================


/**
 * IplImage has no reference counting of underlying data, which creates problems with double 
 * frees after accessing subarrays in python -- instead, replace IplImage with CvMat, which
 * should be functionally equivalent, but has reference counting.
 * The potential shortcomings of this method are 
 * 1. no ROI
 * 2. IplImage fields missing or named something else.
 */
%typemap(in) IplImage * (IplImage header){
	void * vptr;
	int res = SWIG_ConvertPtr($input, (&vptr), $descriptor( CvMat * ), 0);
	if ( res == -1 ){
		SWIG_exception( SWIG_TypeError, "%%typemap(in) IplImage * : could not convert to CvMat");
		SWIG_fail;
	}
	$1 = cvGetImage((CvMat *)vptr, &header);
}

/** For IplImage * return type, there are cases in which the memory should be freed and 
 * some not.  To avoid leaks and segfaults, deprecate this return type and handle cases 
 * individually
 */
%typemap(out) IplImage * {
 	SWIG_exception( SWIG_TypeError, "IplImage * return type is deprecated. Please file a bug report at www.sourceforge.net/opencvlibrary if you see this error message.");
	SWIG_fail;
}

/** macro to convert IplImage return type to CvMat.  Note that this is only covers the case
 *  where the returned IplImage need not be freed.  If the IplImage header needs to be freed,
 *  then CvMat must take ownership of underlying data.  Instead, just handle these limited cases
 *  with CvMat equivalent.
 */
%define %typemap_out_CvMat(func, decl, call)
%rename (func##__Deprecated) func;
%rename (func) func##__CvMat;
%inline %{
CvMat * func##__CvMat##decl{
	IplImage * im = func##call;
	if(im){
		CvMat * mat = (CvMat *)cvAlloc(sizeof(CvMat));
		mat = cvGetMat(im, mat);
		return mat;
	}
	return false;
}
%}
%enddef




// ======================================================
%typemap(in) _IplImage **  (void * vptr, $*1_ltype buffer) {
	if ((SWIG_ConvertPtr($input, &vptr, $*1_descriptor, 1)) == -1){
		SWIG_fail;
	}
	buffer = ($*1_ltype) vptr;
	$1=&buffer;
}
%typemap(in) char **  (void * vptr, $*1_ltype buffer) {
	if ((SWIG_ConvertPtr($input, &vptr, $*1_descriptor, 1)) == -1){
		SWIG_fail;
	}
	buffer = ($*1_ltype) vptr;
	$1=&buffer;
}
%typemap(in) float **  (void * vptr, $*1_ltype buffer) {
	if ((SWIG_ConvertPtr($input, &vptr, $*1_descriptor, 1)) == -1){
		SWIG_fail;
	}
	buffer = ($*1_ltype) vptr;
	$1=&buffer;
}
%typemap(in) unsigned_char **  (void * vptr, $*1_ltype buffer) {
	if ((SWIG_ConvertPtr($input, &vptr, $*1_descriptor, 1)) == -1){
		SWIG_fail;
	}
	buffer = ($*1_ltype) vptr;
	$1=&buffer;
}
%typemap(in) void **  (void * vptr, $*1_ltype buffer) {
	if ((SWIG_ConvertPtr($input, &vptr, $*1_descriptor, 1)) == -1){
		SWIG_fail;
	}
	buffer = ($*1_ltype) vptr;
	$1=&buffer;
}

// ======================================================



// mask some functions that return IplImage *
%ignore cvInitImageHeader;
%ignore cvGetImage;
%ignore cvCreateImageHeader;

// adapt others to return CvMat * instead
%ignore cvCreateImage;
%rename (cvCreateImage) cvCreateImageMat;
%ignore cvCloneImage;
%rename (cvCloneImage) cvCloneImageMat;
%inline %{
extern const signed char icvDepthToType[];
#define icvIplToCvDepth( depth ) \
    icvDepthToType[(((depth) & 255) >> 2) + ((depth) < 0)]
CvMat * cvCreateImageMat( CvSize size, int depth, int channels ){
	depth = icvIplToCvDepth(depth);
	return cvCreateMat( size.height, size.width, CV_MAKE_TYPE(depth, channels));
}
#define cvCloneImageMat( mat ) cvCloneMat( mat )
%}
CvMat * cvCloneImageMat( CvMat * mat );


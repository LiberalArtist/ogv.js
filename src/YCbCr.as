/**
 * Basic YCbCr->RGB conversion
 *
 * @author Brion Vibber <brion@pobox.com>
 * @copyright 2014
 * @license MIT-style
 */
package {
    import flash.utils.ByteArray;

    public class YCbCr {

		/**
		 * @param ybcbr {bytesY, bytesCb, bytesCr, strideY, strideCb, strideCr, width, height, hdec, vdec}
		 * @param output ByteArray to draw ARGB into
		 * Assumes that the output array already has alpha channel set to opaque.
		 */
    	public static function convertYCbCr(ybcbr:Object, output:ByteArray):void {
			var width:int = ybcbr.width,
				height:int = ybcbr.height,
				hdec:int = ybcbr.hdec,
				vdec:int = ybcbr.vdec,
				bytesY:ByteArray = ybcbr.bytesY,
				bytesCb:ByteArray = ybcbr.bytesCb,
				bytesCr:ByteArray = ybcbr.bytesCr,
				strideY:int = ybcbr.strideY,
				strideCb:int = ybcbr.strideCb,
				strideCr:int = ybcbr.strideCr,
				outStride:int = 4 * width,
				YPtr:int, Y0Ptr:int, Y1Ptr:int,
				CbPtr:int, CrPtr:int,
				outPtr:int, outPtr0:int, outPtr1:int,
				colorCb:int, colorCr:int,
				multY:int, multCrR:int, multCbCrG:int, multCbB:int,
				x:int, y:int, xdec:int, ydec:int,
				r:int, g:int, b:int;

			if (hdec == vdec == 1) {
				// Optimize for 4:2:0, which is most common
				outPtr0 = 0;
				outPtr1 = outStride;
				ydec = 0;
				for (y = 0; y < height; y += 2) {
					Y0Ptr = y * strideY;
					Y1Ptr = Y0Ptr + strideY;
					CbPtr = ydec * strideCb;
					CrPtr = ydec * strideCr;
					for (x = 0; x < width; x += 2) {
						colorCb = bytesCb[CbPtr++];
						colorCr = bytesCr[CrPtr++];

						// Quickie YUV conversion
						// https://en.wikipedia.org/wiki/YCbCr#ITU-R_BT.2020_conversion
						// multiplied by 256 for integer-friendliness
						multCrR   = (409 * colorCr) - 57088;
						multCbCrG = (100 * colorCb) + (208 * colorCr) - 34816;
						multCbB   = (516 * colorCb) - 70912;

						multY = (298 * bytesY[Y0Ptr++]);
						r = multY + multCrR;
						g = multY - multCbCrG;
						b = multY + multCbB;
						// Believe it or not these ifs are faster than ?:
						// and WAY faster than a function call!
						if (r & 0xffff0000) {
							if (r < 0) {
								r = 0;
							} else {
								r = 0xffff;
							}
						}
						if (g & 0xffff0000) {
							if (g < 0) {
								g = 0;
							} else {
								g = 0xffff;
							}
						}
						if (b & 0xffff0000) {
							if (b < 0) {
								b = 0;
							} else {
								b = 0xffff;
							}
						}
						outPtr0++;
						output[outPtr0++] = r >> 8;
						output[outPtr0++] = g >> 8;
						output[outPtr0++] = b >> 8;

						multY = (298 * bytesY[Y0Ptr++]);
						r = multY + multCrR;
						g = multY - multCbCrG;
						b = multY + multCbB;
						if (r & 0xffff0000) {
							if (r < 0) {
								r = 0;
							} else {
								r = 0xffff;
							}
						}
						if (g & 0xffff0000) {
							if (g < 0) {
								g = 0;
							} else {
								g = 0xffff;
							}
						}
						if (b & 0xffff0000) {
							if (b < 0) {
								b = 0;
							} else {
								b = 0xffff;
							}
						}
						outPtr0++;
						output[outPtr0++] = r >> 8;
						output[outPtr0++] = g >> 8;
						output[outPtr0++] = b >> 8;

						multY = (298 * bytesY[Y1Ptr++]);
						r = multY + multCrR;
						g = multY - multCbCrG;
						b = multY + multCbB;
						if (r & 0xffff0000) {
							if (r < 0) {
								r = 0;
							} else {
								r = 0xffff;
							}
						}
						if (g & 0xffff0000) {
							if (g < 0) {
								g = 0;
							} else {
								g = 0xffff;
							}
						}
						if (b & 0xffff0000) {
							if (b < 0) {
								b = 0;
							} else {
								b = 0xffff;
							}
						}
						outPtr1++;
						output[outPtr1++] = r >> 8;
						output[outPtr1++] = g >> 8;
						output[outPtr1++] = b >> 8;

						multY = (298 * bytesY[Y1Ptr++]);
						r = multY + multCrR;
						g = multY - multCbCrG;
						b = multY + multCbB;
						if (r & 0xffff0000) {
							if (r < 0) {
								r = 0;
							} else {
								r = 0xffff;
							}
						}
						if (g & 0xffff0000) {
							if (g < 0) {
								g = 0;
							} else {
								g = 0xffff;
							}
						}
						if (b & 0xffff0000) {
							if (b < 0) {
								b = 0;
							} else {
								b = 0xffff;
							}
						}
						outPtr1++;
						output[outPtr1++] = r >> 8;
						output[outPtr1++] = g >> 8;
						output[outPtr1++] = b >> 8;
					}
					outPtr0 += outStride;
					outPtr1 += outStride;
					ydec++;
				}
			} else {
				outPtr = 0;
				for (y = 0; y < height; y++) {
					xdec = 0;
					ydec = y >> vdec;
					YPtr = y * strideY;
					CbPtr = ydec * strideCb;
					CrPtr = ydec * strideCr;

					for (x = 0; x < width; x++) {
						xdec = x >> hdec;
						colorCb = bytesCb[CbPtr + xdec];
						colorCr = bytesCr[CrPtr + xdec];

						// Quickie YUV conversion
						// https://en.wikipedia.org/wiki/YCbCr#ITU-R_BT.2020_conversion
						// multiplied by 256 for integer-friendliness
						multY = 298 * bytesY[YPtr++];
						r = multY + (409 * colorCr) - 57088;
						g = multY - (100 * colorCb) - (208 * colorCr) + 34816;
						b = multY + (516 * colorCb) - 70912;
						if (r & 0xffff0000) {
							if (r < 0) {
								r = 0;
							} else {
								r = 0xffff;
							}
						}
						if (g & 0xffff0000) {
							if (g < 0) {
								g = 0;
							} else {
								g = 0xffff;
							}
						}
						if (b & 0xffff0000) {
							if (b < 0) {
								b = 0;
							} else {
								b = 0xffff;
							}
						}
						outPtr++;
						output[outPtr++] = r >> 8;
						output[outPtr++] = g >> 8;
						output[outPtr++] = b >> 8;
					}
				}
			}
		}
	}
}
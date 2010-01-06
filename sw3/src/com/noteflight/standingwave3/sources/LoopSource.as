///////////////////////////////////////////////////////////////////////////////
//
//  NOTEFLIGHT LLC
//  Copyright 2009 Noteflight LLC
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
////////////////////////////////////////////////////////////////////////////////

package com.noteflight.standingwave3.sources
{
	import com.noteflight.standingwave3.elements.*;
	import com.noteflight.standingwave3.sources.AbstractSource;

	/** 
	 * Creates an audio source of indefinite duration by looping another IDirectAccessSource.
 	 */
	public class LoopSource extends AbstractSource 
	{
		/** The frame to begin and end looping on.
		 * Standing Wave can *not* read loop points from samples. You must provide them.
		 * Of course, loop points should almost ALWAYS be at zero-crossings! 
		 */
		public var startFrame:Number;
		public var endFrame:Number;
		
		/** Factor by which to shift the playback frequency up or down */
		public var frequencyShift:Number;
		
		/** A direct access source to serve as the source of raw sample data */
		private var _generator:IDirectAccessSource;
		
		private var _phase:Number;
		
		
		/** 
		 * LoopSource extends a sample indefinitely by looping a section.
		 * The source of a loop is always a SoundGenerator.
		 */
		public function LoopSource(ad:AudioDescriptor, soundGenerator:IDirectAccessSource, duration:Number)
		{
			super(ad, duration, 1.0);
			this._generator = soundGenerator;
			this.startFrame = startFrame;
			this.endFrame = endFrame;
			this._position = 0;
			this.frequencyShift = 1;
			this._phase = 0;
		}
		
		override public function resetPosition():void 
		{
			_phase = 0;
			_position = 0;
		}
		
		override public function getSample(numFrames:Number):Sample 
		{
			var sample:Sample = new Sample(descriptor, numFrames);
			var tableSize:Number = Math.floor(endFrame);
			
			var phaseAdd:Number = frequencyShift / endFrame; // advance fractionally each frame if shifting
			var phaseReset:Number = startFrame / endFrame; // when end of sample, wrap phase to the loop start point
	
			// Make sure the sound generator is filled to the max time we will need, plus a guard sample for interpolation
			_generator.fill( Math.ceil(_position / frequencyShift) + 1 );
			
			// Scan the wavetable forward, looping appropriately
			// The wavetable function returns the new phase (ie position in the generator)
			_phase = sample.wavetableInDirectAccessSource(_generator, tableSize, _phase, phaseAdd, phaseReset, 0, numFrames);
			_position += numFrames;  
			
			return sample;
			
		}
		
	}
}
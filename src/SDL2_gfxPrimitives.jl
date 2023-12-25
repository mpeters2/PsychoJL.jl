#	SDL2_gfxPrimitives.c
#	https://github.com/RobLoach/sdl2_gfx/blob/edc1880666d5a62e8d58c71cee094c21ba7c5d53/SDL2_gfxPrimitives.c#L1733
#
# Translated to Julia by Matt Peterson, December 2023
#
# semicolon note: Julia is happy with or without semicolons at the end of lines.  I just left them there.

using SimpleDirectMediaLayer
using SimpleDirectMediaLayer.LibSDL2
#using .window

const ELLIPSE_OVERSCAN::Int64 =	4
const AAlevels::Int64 =	 256
const AAbits::Int64 =	 8

truncInt(x) = floor(Int, x)				# for typecasting floats to ints when indexing
#------
lrint(x) = truncInt(round(x))
#-=======================================================================
function line(renderer::Ptr{SDL_Renderer}, x1::Int64, y1::Int64, x2::Int64, y2::Int64)

	return SDL_RenderDrawLine(renderer, x1, y1, x2, y2);
end
#-------------
function vline(renderer::Ptr{SDL_Renderer}, x::Int64, y1::Int64, y2::Int64)
	return SDL_RenderDrawLine(renderer, x, y1, x, y2);;
end
#-------------
function hline(renderer::Ptr{SDL_Renderer}, x1::Int64, x2::Int64, y::Int64)
	return SDL_RenderDrawLine(renderer, x1, y, x2, y);;
end
#-=======================================================================

function pixelRGBA(renderer::Ptr{SDL_Renderer}, x::Int64, y::Int64, r::UInt8, g::UInt8, b::UInt8, a::UInt8)

	result::Int64 = 0;
	result |= SDL_SetRenderDrawBlendMode(renderer, (a == 255) ? SDL_BLENDMODE_NONE : SDL_BLENDMODE_BLEND);
	result |= SDL_SetRenderDrawColor(renderer, r, g, b, a);
	result |= SDL_RenderDrawPoint(renderer, x, y);
	return result;
end
#-------------

function pixelRGBAWeight(renderer::Ptr{SDL_Renderer}, x::Int64, y::Int64, r::UInt8, g::UInt8, b::UInt8, a::UInt8, weight::Int64)

	#=
	* Modify Alpha by weight 
	=#
	ax::UInt8 = a;
	ax = ((ax * weight) >> 8);
	if (ax > 255) 
		a = 255;
	else
		a = ax & 0x000000ff
	end

	return pixelRGBA(renderer, x, y, r, g, b, convert(UInt8, a));
end
#-------------
function pixelColor(renderer::Ptr{SDL_Renderer}, x::Int64, y::Int64, c::Vector{UInt8})
	return pixelRGBA(renderer, x, y, c[1], c[2], c[3], c[4]);
end
#-------------
function pixelColorWeight(renderer::Ptr{SDL_Renderer}, x::Int64, y::Int64, c::Vector{UInt8}, weight::Int64)
	#=
	* Modify Alpha by weight 
	=#
	ax::Int64 = c[4];
	ax = ((ax * weight) >> 8);
	if (ax > 255) 
		c[4] = 255;
	else
		c[4] = ax & 0x000000ff
	end

	return pixelRGBA(renderer, x, y, c[1], c[2], c[3], c[4]);
end
#-=======================================================================
function _drawQuadrants(renderer::Ptr{SDL_Renderer},  x::Int64, y::Int64, dx::Int64, dy::Int64, flag::Bool)

	result::Int64 = 0
	xpdx::Int64 = 0
	xmdx::Int64 = 0
	ypdy::Int64 = 0
	ymdy::Int64 = 0

	if (dx == 0) 
		if (dy == 0) 
			result = result | pixel(renderer, x, y);
		else
			ypdy = y + dy;
			ymdy = y - dy;
			if (flag) 
				result = result | vline(renderer, x, ymdy, ypdy);
			else
				result = result | pixel(renderer, x, ypdy);
				result = result | pixel(renderer, x, ymdy);
			end
		end
	else 
		xpdx = x + dx;
		xmdx = x - dx;
		ypdy = y + dy;
		ymdy = y - dy;
		if (flag) 
			result = result | vline(renderer, xpdx, ymdy, ypdy);
			result = result | vline(renderer, xmdx, ymdy, ypdy);
		else
			result = result | pixel(renderer, xpdx, ypdy);
			result = result | pixel(renderer, xmdx, ypdy);
			result = result | pixel(renderer, xpdx, ymdy);
			result = result | pixel(renderer, xmdx, ymdy);
		end
	end

	return result
end
		
#=!
		brief Internal function to draw ellipse or filled ellipse with blending.

		param renderer The renderer to draw on.
		param x X coordinate of the center of the ellipse.
		param y Y coordinate of the center of the ellipse.
		param rx Horizontal radius in pixels of the ellipse.
		param ry Vertical radius in pixels of the ellipse.
		param r The red value of the ellipse to draw. 
		param g The green value of the ellipse to draw. 
		param b The blue value of the ellipse to draw. 
		param a The alpha value of the ellipse to draw.
		param f Flag indicating if the ellipse should be filled (1) or not (0).

		returns Returns 0 on success, -1 on failure.
=#

#-===========================================================================================================================

function _ellipseRGBA(renderer::Ptr{SDL_Renderer}, x::Int64, y::Int64, rx::Int64, ry::Int64, r::UInt8, g::UInt8, b::UInt8, a::UInt8, flag::Bool)

	result::Int64 = 0
	rx2::Int64 = 0
	ry2::Int64 = 0
	rx22::Int64 = 0
	ry22::Int64 = 0 
	 error::Int64 = 0
	 curX::Int64 = 0 
	curY::Int64 = 0 
	curXp1::Int64 = 0 
	curYm1::Int64 = 0
	scrX::Int64 = 0 
	scrY::Int64 = 0 
	oldX::Int64 = 0 
	oldY::Int64 = 0
	deltaX::Int64 = 0 
	deltaY::Int64 = 0

	#=
	* Sanity check radii 
	=#
	if ((rx < 0) || (ry < 0)) 
		return (-1)
	end

	#=
	* Set color
	=#
	result = 0;
	result |= SDL_SetRenderDrawBlendMode(renderer, (a == 255) ? SDL_BLENDMODE_NONE : SDL_BLENDMODE_BLEND);
	result |= SDL_SetRenderDrawColor(renderer, r, g, b, a);

	#=
	* Special cases for rx=0 and/or ry=0: draw a hline/vline/pixel 
	=#
	if (rx == 0)
		if (ry == 0) 
			return (pixel(renderer, x, y));
		else 
			return (vline(renderer, x, y - ry, y + ry));
		end
	else 
		if (ry == 0) 
			return (hline(renderer, x - rx, x + rx, y));
		end
	end

	#=
	 * Top/bottom center points.
	 =#
	oldX = scrX = 0
	oldY = scrY = ry
	result = result | _drawQuadrants(renderer, x, y, 0, ry, flag)

	#= Midpoint ellipse algorithm with overdraw =#
	rx *= ELLIPSE_OVERSCAN;
	ry *= ELLIPSE_OVERSCAN;
	rx2 = rx * rx;
	rx22 = rx2 + rx2;
	 ry2 = ry * ry;
	ry22 = ry2 + ry2;
	 curX = 0;
	 curY = ry;
	 deltaX = 0;
	 deltaY = rx22 * curY;
 
	#= Points in segment 1 =# 
	 error = ry2 - rx2 * ry + rx2 / 4;
	 while (deltaX <= deltaY)
	 
		curX += 1
		deltaX += ry22;

		error +=  deltaX + ry2; 
		if (error >= 0)

			curY -= 1
			deltaY -= rx22; 
			error -= deltaY;
		end

		scrX = lrint(curX / ELLIPSE_OVERSCAN)
		scrY = lrint(curY / ELLIPSE_OVERSCAN)
		if ((scrX != oldX && scrY == oldY) || (scrX != oldX && scrY != oldY)) 
			result |= _drawQuadrants(renderer, x, y, scrX, scrY, flag);
			oldX = scrX;
			oldY = scrY;
		end
	 end

	#= Points in segment 2 =#
	if (curY > 0) 
	
		curXp1 = curX + 1;
		curYm1 = curY - 1;
		error = lrint(ry2 * curX * curXp1 + ((ry2 + 3) / 4) + rx2 * curYm1 * curYm1 - rx2 * ry2)
		while (curY > 0)
		
			curY -= 1
			deltaY -= rx22;

			error += rx2;
			error -= deltaY;
 
			if (error <= 0) 
				curX += 1
				deltaX += ry22;
				error += deltaX;
			end

		    scrX = lrint(curX/ELLIPSE_OVERSCAN)
		    scrY = lrint(curY/ELLIPSE_OVERSCAN)
		    if ((scrX != oldX && scrY == oldY) || (scrX != oldX && scrY != oldY)) 
				oldY -= 1;
				yyy = oldY
				#for (;oldY >= scrY; oldY -= 1) 
				for  yyy in oldY:-1:scrY
					result |= _drawQuadrants(renderer, x, y, scrX, oldY, flag);
					#= prevent overdraw =#
					if (flag)
						oldY = scrY - 1;
					end
				end
  				oldX = scrX;
				oldY = scrY;
		    end		
		end

		#= Remaining points in vertical =#
		if (!flag) 
			oldY -= 1
			#for (;oldY >= 0; oldY -= 1) 			# equivalent to (for yyy = oldY; zzz >=0; zzz  -= 1)		then assign yyy to oldy when done; Julia for yyy in oldY:-1:0
			yyy = oldY
			for  yyy in oldY:-1:0
				result |= _drawQuadrants(renderer, x, y, scrX, yyy, flag);
			end
			oldY = yyy
		end
	end

	return (result)
end

#=!
		brief Draw ellipse with blending.

		param renderer The renderer to draw on.
		param x X coordinate of the center of the ellipse.
		param y Y coordinate of the center of the ellipse.
		param rx Horizontal radius in pixels of the ellipse.
		param ry Vertical radius in pixels of the ellipse.
		param color The color value of the ellipse to draw (0xRRGGBBAA). 

		returns Returns 0 on success, -1 on failure.
=#
#-===========================================================================================================================
#=!
\brief Draw anti-aliased ellipse with blending.

		\param renderer The renderer to draw on.
		\param x X coordinate of the center of the aa-ellipse.
		\param y Y coordinate of the center of the aa-ellipse.
		\param rx Horizontal radius in pixels of the aa-ellipse.
		\param ry Vertical radius in pixels of the aa-ellipse.
		\param r The red value of the aa-ellipse to draw. 
		\param g The green value of the aa-ellipse to draw. 
		\param b The blue value of the aa-ellipse to draw. 
		\param a The alpha value of the aa-ellipse to draw.

		\returns Returns 0 on success, -1 on failure.
=#
function _aaellipseRGBA(renderer::Ptr{SDL_Renderer}, x::Int64, y::Int64, rx::Int64, ry::Int64, color::Vector{Int64}, flag::Bool)
	aaellipseRGBA(renderer::Ptr{SDL_Renderer}, x::Int64, y::Int64, rx::Int64, ry::Int64, 
							convert(UInt8, color[1]),
							convert(UInt8, color[2]),
							convert(UInt8, color[3]),
							convert(UInt8, color[4]), 
							flag::Bool)
end
# anti-alliased ellipse
function aaellipseRGBA(renderer::Ptr{SDL_Renderer}, x::Int64, y::Int64, rx::Int64, ry::Int64, r::UInt8, g::UInt8, b::UInt8, a::UInt8, flag::Bool)

	result::Int64 = 0
	i::Int64 = 0
	a2::Int64 = 0
	b2::Int64 = 0
	ds::Int64 = 0
	dt::Int64 = 0
	dxt::Int64 = 0
	t::Int64 = 0
	s::Int64 = 0
	d::Int64 = 0
	p::Int64 = 0
	yp::Int64 = 0
	xs::Int64 = 0
	ys::Int64 = 0
	dyt::Int64 = 0
	od::Int64 = 0
	xx::Int64 = 0
	yy::Int64 = 0
	xc2::Int64 = 0
	yc2::Int64 = 0
	cp::Float64 = 0
	sab::Float64 = 0
	weight::Int64 = 0
	iweight::Int64 = 0


	#=
	* Sanity check radii 
	=#
	if ((rx < 0) || (ry < 0)) 
		return (-1);
	end

	#=
	* Special cases for rx=0 and/or ry=0: draw a hline/vline/pixel 
	=#
	if (rx == 0) 
		if (ry == 0) 
			return (pixelRGBA(renderer, x, y, r, g, b, a));
		else 
			return (vlineRGBA(renderer, x, y - ry, y + ry, r, g, b, a));
		end
	else 
		if (ry == 0) 
			return (hlineRGBA(renderer, x - rx, x + rx, y, r, g, b, a));
		end
	end

	#= Variable setup =#
	a2 = rx * rx;
	b2 = ry * ry;

	ds = 2 * a2;
	dt = 2 * b2;

	xc2 = 2 * x;
	yc2 = 2 * y;

	sab = sqrt(a2 + b2)							# sab = sqrt((double)(a2 + b2));
	od = lrint(lrint(sab*0.01) + 1)				#= introduce some overdraw =#
	dxt = lrint(lrint(a2 / sab) + od)

	t = 0;
	s = -2 * a2 * ry;
	d = 0;

	xp = x;
	yp = y - ry;

	#= Draw =#
	result = 0;
	result |= SDL_SetRenderDrawBlendMode(renderer, (a == 255) ? SDL_BLENDMODE_NONE : SDL_BLENDMODE_BLEND);

	#= "End points" =#
	result |= pixelRGBA(renderer, xp, yp, r, g, b, a);
	result |= pixelRGBA(renderer, xc2 - xp, yp, r, g, b, a);
	result |= pixelRGBA(renderer, xp, yc2 - yp, r, g, b, a);
	result |= pixelRGBA(renderer, xc2 - xp, yc2 - yp, r, g, b, a);

	#for (i = 1; i <= dxt; i += 1) 
	for i in 1:dxt
		xp -= 1;
		d += t - b2;

		if (d >= 0)
			ys = yp - 1;
		elseif ((d - s - a2) > 0) 
			if ((2 * d - s - a2) >= 0)
				ys = yp + 1;
			else 
				ys = yp;
				yp += 1;
				d -= s + a2;
				s += ds;
			end
		else 
			yp += 1;
			ys = yp + 1;
			d -= s + a2;
			s += ds;
		end

		t -= dt;

		#= Calculate alpha =#
		if (s != 0) 
			cp = abs(d) / abs(s);		# (float) abs(d) / (float) abs(s);
			if (cp > 1.0) 
				cp = 1.0;
			end
		else 
			cp = 1.0;
		end

		#= Calculate weights =#
		weight = lrint( (cp * 255))
		iweight = 255 - weight;

		#= Upper half =#
		xx = xc2 - xp;							# mirrors xp 
		result |= pixelRGBAWeight(renderer, xp, yp, r, g, b, a, iweight);
		result |= pixelRGBAWeight(renderer, xx, yp, r, g, b, a, iweight);

		result |= pixelRGBAWeight(renderer, xp, ys, r, g, b, a, weight);
		result |= pixelRGBAWeight(renderer, xx, ys, r, g, b, a, weight);


##hline(renderer, xp, xx, yp);
#hline(renderer, xp, xx, ys);


		#= Lower half =#
		yy = yc2 - yp;							# mirrors yp
		result |= pixelRGBAWeight(renderer, xp, yy, r, g, b, a, iweight);
		result |= pixelRGBAWeight(renderer, xx, yy, r, g, b, a, iweight);

		yy = yc2 - ys;
		result |= pixelRGBAWeight(renderer, xp, yy, r, g, b, a, weight);
		result |= pixelRGBAWeight(renderer, xx, yy, r, g, b, a, weight);
	end

	#= Replaces original approximation code dyt = abs(yp - yc); =#
	dyt = lrint(b2 / sab ) + od;    

	#for (i = 1; i <= dyt; i += 1) 
	for i in 1:dyt
		yp += 1;
		d -= s + a2;

		if (d <= 0)
			xs = xp + 1;
		elseif ((d + t - b2) < 0) 
			if ((2 * d + t - b2) <= 0)
				xs = xp - 1;
			else 
				xs = xp;
				xp -= 1;
				d += t - b2;
				t -= dt;
			end
		else 
			xp -= 1;
			xs = xp - 1;
			d += t - b2;
			t -= dt;
		end

		s += ds;

		#= Calculate alpha =#
		if (t != 0) 
			cp =  abs(d) /  abs(t);				# MSP this had (float)...does it matter in Julia?   
			if (cp > 1.0) 
				cp = 1.0;
			end
		else 
			cp = 1.0;
		end

		#= Calculate weight =#
		weight = lrint( (cp * 255) )
		iweight = 255 - weight;

		#= Left half =#
		xx = xc2 - xp;
		yy = yc2 - yp;
		result |= pixelRGBAWeight(renderer, xp, yp, r, g, b, a, iweight);
		result |= pixelRGBAWeight(renderer, xx, yp, r, g, b, a, iweight);

		result |= pixelRGBAWeight(renderer, xp, yy, r, g, b, a, iweight);
		result |= pixelRGBAWeight(renderer, xx, yy, r, g, b, a, iweight);
#vline(renderer, xp, yp, yy);
#vline(renderer, xx, yp, yy);
		#= Right half =#
		xx = xc2 - xs;
		result |= pixelRGBAWeight(renderer, xs, yp, r, g, b, a, weight);
		result |= pixelRGBAWeight(renderer, xx, yp, r, g, b, a, weight);

		result |= pixelRGBAWeight(renderer, xs, yy, r, g, b, a, weight);
		result |= pixelRGBAWeight(renderer, xx, yy, r, g, b, a, weight);		
#vline(renderer, xs, yp, yy);
#vline(renderer, xx, yp, yy);
	end

	return (result)
end
#-============================================================================================================================================================
# function to draw anti-aliased filled ellipse
#	int aaFilledEllipseRGBA(SDL_Renderer * renderer, float cx, float cy, float rx, float ry, Uint8 r, Uint8 g, Uint8 b, Uint8 a)
#----------
function aaFilledEllipseRGBA(renderer::Ptr{SDL_Renderer}, cx::Int64, cy::Int64, rx::Int64, ry, r::Int64, g::Int64, b::Int64, a::Int64)
	aaFilledEllipseRGBA(renderer, 
						convert(Float64, cx),
						convert(Float64, cy),
						convert(Float64, rx),
						convert(Float64, ry),
						convert(UInt8, r),
						convert(UInt8, g),
						convert(UInt8, b),
						convert(UInt8, a)

	)
end
#----------
function aaFilledEllipseRGBA(renderer::Ptr{SDL_Renderer}, cx::Float64, cy::Float64, rx::Float64, ry::Float64, r::UInt8, g::UInt8, b::UInt8, a::UInt8)

	n::Int64 = 0
	xi::Int64 = 0
	yi::Int64 = 0
	result::Int64 = 0
	
	s::Float64 = 0
	v::Float64 = 0
	x::Float64 = 0
	y::Float64 = 0
	dx::Float64 = 0
	dy::Float64 = 0


	if ((rx <= 0.0) || (ry <= 0.0))
		return -1 ;
	end
	result |= SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_BLEND) ;
	if (rx >= ry)
		
		n = ry + 1 ;
		#for (yi = cy - n - 1; yi <= cy + n + 1; yi++)
		for yi in (cy - n):1:(cy + n + 2)
		
			if (yi < (cy - 0.5))
				y = yi ;
			else
				y = yi + 1 ;
			end
			s = (y - cy) / ry ;
			s = s * s ;
			x = 0.5 ;
			if (s < 1.0)
				x = rx * sqrt(1.0 - s) ;
				if (x >= 0.5)		
					result |= SDL_SetRenderDrawColor(renderer, r, g, b, a ) ;
					result |= renderdrawline(renderer, cx - x + 1, yi, cx + x - 1, yi) ;
				end
			end
			s = 8 * ry * ry ;
			dy = abs(y - cy) - 1.0 ;
			xi = trunc(cx - x) ; # left
			while (true)
				
				dx = (cx - xi - 1) * ry / rx ;
				v = s - 4 * (dx - dy) * (dx - dy) ;
				if (v < 0) 
					break ;
				end
				v = (sqrt(v) - 2 * (dx + dy)) / 4 ;
				if (v < 0) 
					break ;
				end
				if (v > 1.0) 
					v = 1.0 ;
				end
				result |= SDL_SetRenderDrawColor(renderer, r, g, b, truncInt(a * v) ) ;
				result |= SDL_RenderDrawPoint(renderer, xi, yi) ;
				xi -= 1 ;
			end
			xi = trunc(cx + x) ; # right
			while (true)
				
				dx = (xi - cx) * ry / rx ;
				v = s - 4 * (dx - dy) * (dx - dy) ;
				if (v < 0) 
					break ;
				end
				v = (sqrt(v) - 2 * (dx + dy)) / 4 ;
				if (v < 0) 
					break ;
				end
				if (v > 1.0) 
					v = 1.0 ;
				end
				result |= SDL_SetRenderDrawColor(renderer, r, g, b, truncInt(a * v) ) ;
				result |= SDL_RenderDrawPoint(renderer, xi, yi) ;
				xi += 1 ;
			end
		end
	else
		n = rx + 1 ;
		#for (xi = cx - n - 1; xi <= cx + n + 1; xi++)
		for xi in (cx - n - 0):1:( cx + n + 2)
			
			if (xi < (cx - 0.5))
				x = xi ;
			else
				x = xi + 1 ;
			end
			s = (x - cx) / rx ;
			s = s * s ;
			y = 0.5 ;
			if (s < 1.0)		
				y = ry * sqrt(1.0 - s) ;
				if (y >= 0.5)
					result |= SDL_SetRenderDrawColor(renderer, r, g, b, a ) ;
					result |= renderdrawline(renderer, xi, cy - y + 1, xi, cy + y - 1) ;
				end
			end
			
			s = 8 * rx * rx ;
			dx = abs(x - cx) - 1.0 ;
			yi = trunc(cy - y) ; # top
			while (true)
				
				dy = (cy - yi - 1) * rx / ry ;
				v = s - 4 * (dy - dx) * (dy - dx) ;
				if (v < 0) 
					break ;
				end
				v = (sqrt(v) - 2 * (dy + dx)) / 4 ;
				if (v < 0) 
					break ;
				end
				if (v > 1.0) 
					v = 1.0 ;
				end
				result |= SDL_SetRenderDrawColor(renderer, r, g, b, truncInt(a * v) ) ;
				result |= SDL_RenderDrawPoint(renderer, xi, yi) ;
				yi -= 1 ;
			end
			yi = trunc(cy + y) ; # bottom
			while (true)
				
				dy = (yi - cy) * rx / ry ;
				v = s - 4 * (dy - dx) * (dy - dx) ;
				if (v < 0)
					break ;
				end
				v = (sqrt(v) - 2 * (dy + dx)) / 4 ;
				if (v < 0)
					break ;
				end
				if (v > 1.0) 
					v = 1.0 ;
				break
				result |= SDL_SetRenderDrawColor(renderer, r, g, b, a * v) ;
				result |= SDL_RenderDrawPoint(renderer, xi, yi) ;
				yi += 1 ;
			end
		end
	end
	return result ;
end
end

#---------------------------
function renderdrawline(renderer::Ptr{SDL_Renderer}, x1::Int64, y1::Int64, x2::Int64, y2::Int64)

#ifndef __EMSCRIPTEN__
#=	if ((x1 == x2) && (y1 == y2))
		result = SDL_RenderDrawPoint (renderer, x1, y1) ;
	else if (y1 == y2)
	    {
		int x ;
		if (x1 > x2) { x = x1 ; x1 = x2 ; x2 = x ; }
		SDL_Point *points = (SDL_Point*) malloc ((x2 - x1 + 1) * sizeof(SDL_Point)) ;
		if (points == NULL) return -1 ;
		for (x = x1; x <= x2; x++)
		    {
			points[x - x1].x = x ;
			points[x - x1].y = y1 ;
		    }
		result = SDL_RenderDrawPoints (renderer, points, x2 - x1 + 1) ;
		free (points) ;
	    }
	else if (x1 == x2)
	    {
		int y ;
		if (y1 > y2) { y = y1 ; y1 = y2 ; y2 = y ; }
		SDL_Point *points = (SDL_Point*) malloc ((y2 - y1 + 1) * sizeof(SDL_Point)) ;
		if (points == NULL) return -1 ;
		for (y = y1; y <= y2; y++)
		    {
			points[y - y1].x = x1 ;
			points[y - y1].y = y ;
		    }
		result = SDL_RenderDrawPoints (renderer, points, y2 - y1 + 1) ;
		free (points) ;
	    }
	else
=#
#endif
		result = SDL_RenderDrawLine(renderer, x1, y1, x2, y2) ;
	return result ;
end
#-----------
function renderdrawline(renderer::Ptr{SDL_Renderer}, x1::Float64, y1::Float64, x2::Float64, y2::Float64)
	return SDL_RenderDrawLine(renderer, 
							truncInt(x1), 			# C would trunc floats to ints, so I'm not rounding
							truncInt(y1), 
							truncInt(x2), 
							truncInt(y2)
							)
end
#-===========================================================================================================================
# unfilled ellipse
function ellipseRGBA(renderer::Ptr{SDL_Renderer}, x::Int64, y::Int64, rx::Int64, ry::Int64, r::UInt8, g::UInt8, b::UInt8, a::UInt8)

	return _ellipseRGBA(renderer, x, y, rx, ry, r, g, b, a, false);
end
#---------------
# filled ellipse
function filledEllipseRGBA(renderer::Ptr{SDL_Renderer}, x::Int64, y::Int64, rx::Int64, ry::Int64, r::UInt8, g::UInt8, b::UInt8, a::UInt8)

	return _ellipseRGBA(renderer, x, y, rx, ry, r, g, b, a, true);
end
#-===========================================================================================================================
# unfilled circle
function circleRGBA(renderer::Ptr{SDL_Renderer}, x::Int64, y::Int64, radius::Int64, r::UInt8, g::UInt8, b::UInt8, a::UInt8)

	return ellipseRGBA(renderer, x, y, radius, radius, r, g, b, a);
end
#---------------
# filled circle
function filledCircleRGBA(renderer::Ptr{SDL_Renderer}, x::Int64, y::Int64, radius::Int64, r::UInt8, g::UInt8, b::UInt8, a::UInt8)

	return _ellipseRGBA(renderer, x, y, radius, radius, r, g ,b, a, true);
end

#-===========================================================================================================================
#-===========================================================================================================================

function thickLineRGBA(renderer::Ptr{SDL_Renderer}, x1::Int64, y1::Int64, x2::Int64, y2::Int64, width::Int64, r::Int64, g::Int64, b::Int64, a::Int64)
	result::Int64 = 0;
	wh::Int64 = 1;
	LineStyle::Int64 = -1;

	if (renderer == C_NULL)
		return -1;
	end
	if (width < 1) 
		return -1;
	end

	# Special case: thick "point" 
	if ((x1 == x2) && (y1 == y2)) 
		wh = width / 2;
		return boxRGBA(renderer, x1 - wh, y1 - wh, x2 + width, y2 + width, r, g, b, a);         
	end

	# Set color
	result = 0;
	if (a != 255) 
		result |= SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_BLEND);
	end
	result |= SDL_SetRenderDrawColor(renderer, r, g, b, a);

	#
	draw_varthick_line(renderer, LineStyle, x1, y1, x2, y2, convert(Float64, width)); 	
	return(result);
end
#-===========================================================================================================================

function draw_varthick_line(B::Ptr{SDL_Renderer}, style::Int64, x0::Int64,y0::Int64, x1::Int64, y1::Int64, thickness::Float64)
 	dx::Int64 = 0
	dy::Int64 = 0
	xstep::Int64 = 0
	ystep::Int64 = 0
	pxstep::Int64 = 0
	pystep::Int64 = 0;

	dx= x1-x0;
	dy= y1-y0;
	xstep= ystep= 1;

	if (dx<0) 
		dx= -dx; xstep= -1; 
	end
	if (dy<0) 
		dy= -dy; ystep= -1; 
	end

	if (dx==0) 
		xstep= 0;
	end
	if (dy==0) 
		ystep= 0;
	end

	if (xstep + ystep*4) == ( -1 + -1*4 )
		pystep= -1; pxstep= 1; 				# -5
	elseif (xstep + ystep*4) == (-1 +  0*4)
		pystep= -1; pxstep= 0; 				# -1
	elseif (xstep + ystep*4) == (-1 +  1*4)
		pystep=  1; pxstep= 1; 				# 3
	elseif (xstep + ystep*4) == (0 + -1*4)
		pystep=  0; pxstep= -1; 				# -4
	elseif (xstep + ystep*4) == (0 +  0*4)
		pystep=  0; pxstep= 0; 				# 0
	elseif (xstep + ystep*4) == (0 +  1*4)
		pystep=  0; pxstep= 1; 				# 4
	elseif (xstep + ystep*4) == (1 + -1*4)
		pystep= -1; pxstep= -1; 				# -3
	elseif (xstep + ystep*4) == (1 +  0*4)
		pystep= -1; pxstep= 0;  				# 1
	elseif (xstep + ystep*4) == (1 +  1*4)
		pystep=  1; pxstep= -1; 				# 5
	end
	#=
	switch(xstep + ystep*4)
	{
		case -1 + -1*4 :  pystep= -1; pxstep= 1; break;   		# -5
		case -1 +  0*4 :  pystep= -1; pxstep= 0; break;   		# -1
		case -1 +  1*4 :  pystep=  1; pxstep= 1; break;   		# 3
		case  0 + -1*4 :  pystep=  0; pxstep= -1; break;  		# -4
		case  0 +  0*4 :  pystep=  0; pxstep= 0; break;   		# 0
		case  0 +  1*4 :  pystep=  0; pxstep= 1; break;   		# 4
		case  1 + -1*4 :  pystep= -1; pxstep= -1; break;  		# -3
		case  1 +  0*4 :  pystep= -1; pxstep= 0;  break;  		# 1
		case  1 +  1*4 :  pystep=  1; pxstep= -1; break;  		# 5
	}
	=#
	if (dx>dy) 
		x_varthick_line(B,style,x0,y0,dx,dy,xstep,ystep,
												thickness+1.0,
												pxstep,pystep);
	else 
		y_varthick_line(B,style,x0,y0,dx,dy,xstep,ystep,
												thickness+1.0,
												pxstep,pystep);
	end
	return;
end


#-===========================================================================================================================

function y_varthick_line(B::Ptr{SDL_Renderer}, 
							style::Int64, 
							x0::Int64, 
							y0::Int64, 
							dx::Int64, 
							dy::Int64, 
							xstep::Int64, 
							ystep::Int64, 
							thickness::Float64, 
							pxstep::Int64, 
							pystep::Int64
						)

	p_error::Int64 = 0
	error::Int64 = 0
	x::Int64 = x0
	y::Int64 = y0
	threshold::Int64 = dy - 2*dx;
	E_diag::Int64 = -2*dy
	E_square::Int64 = 2*dx
	length::Int64 =  dy+1
	p::Int64 = 0
	D::Float64= sqrt(dx*dx+dy*dy);
	w_left::Int64 =	lrint(thickness*D + 0.5)
	w_right::Int64 = lrint(2.0 * thickness*D + 0.5)
	w_right -= w_left;	
	#=
	D::Float64 = 0.0

	p_error= 0;
	error= 0;
	y= y0;
	x= x0;
	threshold = dy - 2*dx;
	E_diag= -2*dy;
	E_square= 2*dx;
	length = dy+1;
	w_left=	thickness*D + 0.5;
	w_right= 2.0*thickness*D + 0.5;
	=#

#	for(p=0;p<length;p++)	
	for p in 0:1:length
		style = (style << 1) | (style < 0);
		if (style < 0)
			y_perpendicular(B,x,y, dx, dy, pxstep, pystep, p_error,w_left,w_right,error);
		end
		if (error>=threshold)
			x = x + xstep;
			error = error + E_diag;
			if (p_error>=threshold)
				if (style < 0)
					y_perpendicular(B, x, y, dx, dy, pxstep, pystep,
									p_error+E_diag+E_square,
									w_left, w_right, error);
				end
				p_error= p_error + E_diag;
			end
			p_error= p_error + E_square;
		end
		error = error + E_square;
		y= y + ystep;
	end
end
#-===========================================================================================================================
function y_perpendicular(B::Ptr{SDL_Renderer},
                            x0::Int64, y0::Int64, dx::Int64, dy::Int64, xstep::Int64, ystep::Int64,
                            einit::Int64, w_left::Int64, w_right::Int64, winit::Int64
							)

	threshold::Int64 = dy - 2*dx
	E_diag::Int64 = -2*dy
	E_square::Int64 = 2*dx
	tk::Int64 = dx + dy + winit

	error::Int64 = -einit


	p::Int64 = 0
	q::Int64 = 0;

	y::Int64 = y0;
	x::Int64 = x0;



	while(tk<=w_left)
	
		SDL_RenderDrawPoint(B,x,y);
		if (error>threshold)
		
			y= y + ystep;
			error = error + E_diag;
			tk= tk + 2*dx;
		end
		error = error + E_square;
		x= x + xstep;
		tk= tk + 2*dy;
		q += 1
	end

	y= y0;
	x= x0;
	error = einit;
	tk= dx + dy - winit; 

	while(tk<=w_right)
	
		if (p > 0)
			SDL_RenderDrawPoint(B,x,y);
		end
		if (error>=threshold)
		
			y= y - ystep;
			error = error + E_diag;
			tk= tk + 2*dx;
		end
		error = error + E_square;
		x= x - xstep;
		tk= tk + 2*dy;
		p +=1;
	end

	if (q==0 && p<2) 
		SDL_RenderDrawPoint(B,x0,y0); 		# we need this for very thin lines
	end
end
#-============================================================================================================================================================
#-============================================================================================================================================================
function _aalineRGBA(renderer::Ptr{SDL_Renderer}, x1::Int64, y1::Int64, x2::Int64, y2::Int64, r::Int64, g::Int64, b::Int64, a::Int64, draw_endpoint::Bool)

	result::Int32 = 0;
	intshift::Int32 = 0
	erracc::Int32 = 0
	erracctmp::Int32 = 0
	wgt::Int32 = 0

	dx::UInt32 = 0
	dy::UInt32 = 0
	tmp::Int32 = 0
	xdir::Int32 = 0
	y0p1::Int32 = 0
	x0pxdir::Int32 = 0


	#=
	* Keep on working with 32bit numbers 
	=#
	xx0::Int32 = x1;
	yy0::Int32 = y1;
	xx1::Int32 = x2;
	yy1::Int32 = y2;

	#=
	* Reorder points to make dy positive 
	=#
	if (yy0 > yy1) 
		tmp = yy0;
		yy0 = yy1;
		yy1 = tmp;
		tmp = xx0;
		xx0 = xx1;
		xx1 = tmp;
	end

	#=
	* Calculate distance 
	=#
	dx = xx1 - xx0;
	dy = yy1 - yy0;

	#=
	* Adjust for negative dx and set xdir 
	=#
	if (dx >= 0) 
		xdir = 1;
	else 
		xdir = -1;
		dx = (-dx);
	end
	
	#=
	* Check for special cases 
	=#
	if (dx == 0) 
		#=
		* Vertical line 
		=#
		if (draw_endpoint)
		
			return (vlineRGBA(renderer, x1, y1, y2, r, g, b, a));
		else 
			if (dy > 0) 
				return (vlineRGBA(renderer, x1, yy0, yy0+dy, r, g, b, a));
			else 
				return (pixelRGBA(renderer, x1, y1, r, g, b, a));
			end
		end
	elseif (dy == 0) 
		#=
		* Horizontal line 
		=#
		if (draw_endpoint)
		
			return (hlineRGBA(renderer, x1, x2, y1, r, g, b, a));
		else 
			if (dx > 0) 
				return (hlineRGBA(renderer, xx0, xx0+(xdir*dx), y1, r, g, b, a));
			else 
				return (pixelRGBA(renderer, x1, y1, r, g, b, a));
			end
		end
	elseif ((dx == dy) && (draw_endpoint)) 
		#=
		* Diagonal line (with endpoint)
		=#
		return (lineRGBA(renderer, x1, y1, x2, y2,  r, g, b, a));
	end


	#=
	* Line is not horizontal, vertical or diagonal (with endpoint)
	=#
	result = 0;

	#=
	* Zero accumulator 
	=#
	erracc = 0;

	#=
	* # of bits by which to shift erracc to get intensity level 
	=#
	intshift = 32 - AAbits;

	#=
	* Draw the initial pixel in the foreground color 
	=#
	result |= pixelRGBA(renderer, x1, y1, r, g, b, a);

	#=
	* x-major or y-major? 
	=#
	if (dy > dx) 
			#=
			* y-major.  Calculate 16-bit fixed point fractional part of a pixel that
			* X advances every time Y advances 1 pixel, truncating the result so that
			* we won't overrun the endpoint along the X axis 
			=#
			#=
			* Not-so-portable version: erradj = ((Uint64)dx << 32) / (Uint64)dy; 
			=#
		#erradj = ((dx << 16) / dy) << 16;
		erradj = (dx << 32) / dy
			#=
			* draw all pixels other than the first and last 
			=#
		x0pxdir = xx0 + xdir;
		#while (--dy) 
		println("\n dy: ", dy,"\n")
		
		while (dy > 0)			# << what does this do?
			dy -= 1
			erracctmp = erracc;
			erracc += trunc(erradj);
			if (erracc <= erracctmp) 
				#=
				* rollover in error accumulator, x coord advances 
				=#
				xx0 = x0pxdir;
				x0pxdir += xdir;
			end
			yy0 += 1;		#= y-major so always advance Y =#

			#=
			* the AAbits most significant bits of erracc give us the intensity
			* weighting for this pixel, and the complement of the weighting for
			* the paired pixel. 
			=#
			wgt = (erracc >> intshift) & 255;
			result |= pixelRGBAWeight(renderer, convert(Int64, xx0 ), convert(Int64, yy0 ), r, g, b, a, 255 - wgt);
			result |= pixelRGBAWeight(renderer, convert(Int64, x0pxdir), convert(Int64, yy0), r, g, b, a, convert(Int64, wgt) );
		end

	else 

		#=
		* x-major line.  Calculate 16-bit fixed-point fractional part of a pixel
		* that Y advances each time X advances 1 pixel, truncating the result so
		* that we won't overrun the endpoint along the X axis. 
		=#
		#=
		* Not-so-portable version: erradj = ((Uint64)dy << 32) / (Uint64)dx; 
		=#
		#erradj = ((dy << 16) / dx) << 16;
		erradj = (dx << 32) / dy

		#=
		* draw all pixels other than the first and last 
		=#
		y0p1 = yy0 + 1;
		#while (--dx) 
		while (dx -= 1) 
			erracctmp = erracc;
			erracc += erradj;
			if (erracc <= erracctmp) 
				#=
				* Accumulator turned over, advance y 
				=#
				yy0 = y0p1;
				y0p1 += 1;
			end
			xx0 += xdir;	#= x-major so always advance X =#
			#=
			* the AAbits most significant bits of erracc give us the intensity
			* weighting for this pixel, and the complement of the weighting for
			* the paired pixel. 
			=#
			wgt = (erracc >> intshift) & 255;
			result |= pixelRGBAWeight(renderer, convert(Int64, xx0), convert(Int64, yy0), r, g, b, a, 255 - wgt);
			result |= pixelRGBAWeight(renderer, convert(Int64, xx0), convert(Int64, y0p1), r, g, b, a, convert(Int64, wgt) );
		end
	end

	#=
	* Do we have to draw the endpoint 
	=#
	if (draw_endpoint) 
		#=
		* Draw final pixel, always exactly intersected by the line and doesn't
		* need to be weighted. 
		=#
		result |= pixelRGBA(renderer, x2, y2, r, g, b, a);
	end

	return (result);
end

#-============================================================================================================================================================

function lineRGBA(renderer::Ptr{SDL_Renderer}, x1::Int64, y1::Int64, x2::Int64, y2::Int64, r::UInt64, g::UInt64, b::UInt64, a::UInt64)

	result::Int16 = 0;
	if (a != 255) 
		result |= SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_BLEND);
	end
	result |= SDL_SetRenderDrawColor(renderer, r, g, b, a);	
	result |= SDL_RenderDrawLine(renderer, x1, y1, x2, y2);
	return result;
end
#-============================================================================================================================================================
# This one works in Julia.  Could not get _aalineRGBA to work at all without jaggies.
# below is the original from Mike Abrash's Black Box book
#renderer::Ptr{SDL_Renderer}, x1::Int64, y1::Int64, x2::Int64, y2::Int64, r::Int64, g::Int64, b::Int64, a::Int64, draw_endpoint::Bool)
function DrawWuLine(renderer::Ptr{SDL_Renderer}, X0::Int64, Y0::Int64, X1::Int64, Y1::Int64, r::UInt64, g::UInt64, b::UInt64, a::UInt64)

	IntensityShift::UInt32 = 0
	ErrorAdj::UInt32 = 0
	ErrorAcc::UInt32 = 0;
	ErrorAccTemp::UInt32 = 0
	Weighting::UInt32 = 0
	WeightingComplementMask::UInt32 = 0
	
	DeltaX::Int32 = 0
	DeltaY::Int32 = 0
	Temp::Int32 = 0
	XDir::Int32 = 0

	#= Make sure the line runs top to bottom =#
	if (Y0 > Y1)
		Temp = Y0; 
		Y0 = Y1; 
		Y1 = Temp; 
		Temp = X0; 
		X0 = X1; 
		X1 = Temp;
	end	

	#= Draw the initial pixel, which is always exactly intersected by the line and so needs no weighting =#
	#DrawPixel(X0, Y0, BaseColor);
	pixelRGBA(renderer, convert(Int64, X0), convert(Int64, Y0), r, g, b, a);
	if ((DeltaX = X1 - X0) >= 0) 
		XDir = 1;
	else
		Dir = -1;
		DeltaX = -DeltaX; #= make DeltaX positive =# 
	end	

	#= Special-case horizontal, vertical, and diagonal lines, which require no weighting because they go right through the center of every pixel =#
	if ((DeltaY = Y1 - Y0) == 0)
		#= Horizontal line =# 
		DeltaX -= 1
		while (DeltaX != 0)
			X0 += XDir;
			pixelRGBA(renderer, convert(Int64, X0), convert(Int64, Y0), r, g, b, a)
			DeltaX -= 1
		end
		return
	end
	if DeltaX == 0
		# vertical line
		while DeltaY != 0
			Y0 += 1
			pixelRGBA(renderer, convert(Int64, X0), convert(Int64, Y0), r, g, b, a)
			DeltaY -= 1
		end
		return
	end
	if DeltaX == DeltaY
		# diagonal line
		while DeltaY != 0
			X0 += XDir;
			Y0 += 1
			DeltaY -= 1
		end
		return
	end

	#= line is not horizontal, diagonal, or vertical =#
	ErrorAcc =0			# initialize the line error accumulator to 0
	# # of bits by which to shift ErrorAcc to get intensity level
	IntensityShift = 16 - AAbits
	#= Mask used to flip all bits in an intensity weighting, producing the 
	result (1 - intensity weighting) =#
	WeightingComplementMask = AAlevels - 1; 
	#= Is this an X-major or Y-major line? =# 
	if (DeltaY > DeltaX)
		#= Y-major line; calculate 16-bit fixed-point fractional part of a 
			pixel that X advances each time Y advances 1 pixel, truncating the 
			result so that we won't overrun the endpoint along the X axis =#
		#ErrorAdj = ((unsigned long) DeltaX << 16) / (unsigned long) DeltaY; #= Draw all pixels other than the first and last =#
println(DeltaX,", ",DeltaY)
		ErrorAdj = truncInt( ( DeltaX << 16) /  DeltaY )
		#= Draw all pixels other than the first and last =#
		while (DeltaY > 0) 

			ErrorAccTemp = ErrorAcc; 			#= remember currrent accumulated error =# 
			ErrorAcc += ErrorAdj; 				#= calculate error for next pixel =#
			if (ErrorAcc <= ErrorAccTemp)
				#= The error accumulator turned over, so advance the X coord =#
				X0 += XDir; 
			end	

			Y0 +=1; 							#= Y-major, so always advance Y =#
				#= The IntensityBits most significant bits of ErrorAcc give us the
				intensity weighting for this pixel, and the complement of the
				weighting for the paired pixel =#
			Weighting = ErrorAcc >> IntensityShift; 
			#DrawPixel(X0, Y0, BaseColor + Weighting); 
			pixelRGBAWeight(renderer, convert(Int64, X0), convert(Int64, Y0), r, g, b, a, convert(Int64, Weighting))
			#DrawPixel(X0 + XDir, Y0, BaseColor + (Weighting ^ WeightingComplementMask));
			pixelRGBAWeight(renderer, convert(Int64, X0 + XDir), convert(Int64, Y0), r, g, b, a, convert(Int64, Weighting ^ WeightingComplementMask) );
			#pixelRGBAWeight(renderer, convert(Int64, X0 + XDir), convert(Int64, Y0), r, g, b, a, convert(Int64, wgt) );
			DeltaY -= 1
		end	
		#= Draw the final pixel, which is always exactly intersected by the line and so needs no weighting =#
		pixelRGBA(renderer, convert(Int64, X1), convert(Int64, Y1), r, g, b, a)
		return
	end
	#= It's an X-major line; calculate pixel that Y advances each time result to avoid overrunning the
		16-bit fixed-point fractional part of a X advances 1 pixel, truncating the endpoint along the X axis =#
	#ErrorAdj = ((unsigned long) DeltaY << 16) / (unsigned long) DeltaX; #= Draw all pixels other than the first and last =#
	ErrorAdj = truncInt( ( DeltaY << 16) /  DeltaX) 			#= Draw all pixels other than the first and last =#
	DeltaX -= 1
	#while (--DeltaX)
	while DeltaX > 0
		ErrorAccTemp = ErrorAcc; 					#= remember currrent accumulated error =# 
		ErrorAcc += ErrorAdj; 						#= calculate error for next pixel =#
		if (ErrorAcc <= ErrorAccTemp)
			#= The error accumulator turned over, so advance the Y coord =#
			Y0 += 1 
		end
		X0 += XDir; 								#= X-major, so always advance X =#
		#= The IntensityBits most significant bits of ErrorAcc give us the
			intensity weighting for this pixel, and the complement of the
			weighting for the paired pixel =#
		Weighting = ErrorAcc >> IntensityShift; 
		#DrawPixel(X0, Y0, BaseColor + Weighting); 
		#DrawPixel(X0, Y0 + 1, BaseColor + (Weighting ^ WeightingComplementMask));
		pixelRGBAWeight(renderer, convert(Int64, X0), convert(Int64, Y0), r, g, b, a, convert(Int64, Weighting))
		pixelRGBAWeight(renderer, convert(Int64, X0), convert(Int64, Y0 + 1), r, g, b, a, convert(Int64, Weighting ^ WeightingComplementMask) );

		DeltaX -= 1
	end
	#= Draw the final pixel, which is always exactly intersected by the line and so needs no weighting =#
	pixelRGBA(renderer, convert(Int64, X1), convert(Int64, Y1), r, g, b, a)
end


#-====================================================================================
# returns fractional part of any number.
function fpart( x::Float64)
    return (x-floor(x))
end
#----
function rfpart( x::Float64)
    return (1-fpart(x));
end

#----
# https://en.wikipedia.org/wiki/Talk%3AXiaolin_Wu%27s_line_algorithm
# void WULinesAlpha(double x1,double y1,double x2,double y2,Uint32 color,SDL_Surface* screen)
function WULinesAlpha(win::Window, x1::Float64, y1::Float64, x2::Float64, y2::Float64, colR::UInt8, colG::UInt8, colB::UInt8, colAlpha::UInt8)
	vertical::Bool =false;
	r::UInt8 = 0
	g::UInt8 = 0

	b::UInt8 = 0
	# temporary Surface with alpha support.
#	screen =  SDL_GetWindowSurface(win)
#	alpha = SDL_CreateRGBSurface(SDL_ALPHA_OPAQUE,WIDTH,HEIGHT,32, 0x000000FF, 0x0000FF00, 0x00FF0000, 0xFF000000);
	#SDL_GetRGB(color,screen.format, r, g, b);
	# new color but with alpha value.
	#colorAlpha = SDL_MapRGBA(alpha.format,r,g,b,255);
	orignalAlpha = colAlpha
	#colorAlpha = SDL_Color(colR, colG, colB, colAlpha)		
	colorAlpha::Vector{UInt8} = [	colR, colG, colB, colAlpha]
	# checking if this is a vertical or horizental line type.
	if(abs(y2-y1)>abs(x2-x1))
		vertical=true;
	end
	# make vertical lines horizental.
	if (vertical)
		temp = x1
		x1 = y1
		y1 = temp
		temp = x2
		x2 = y2
		y2 = temp
	end
	# if x is decreasing swap x1 and x2;
	if (x2 < x1)
		temp = x1
		x1 = x2
		x2 = temp	
		temp = y1
		y1 = y2
		y2 = temp
	end
	# line WIDTH and HEIGHT!!!
	dx::Int32 = lrint(x2 - x1);
	dy::Int32  = lrint(y2 - y1);
	# this is for calculating y from x ;)
	gradient::Float64 = (dy) / (dx);
	#  handle first endpoint. endpoints will be handle seperately. cuz they are thricky.
	#  wu's line algorithm can draw lines with non integer start and end. so we need to
	# have an integer to start with.
	xend::Int32 = round(x1);
	# some good y for end point this is also an int.
	yend::Float64 = y1 + gradient * (xend - x1);
	# xgap is simply pixel around integer
	xgap::Float64 = rfpart(x1 + 0.5);
	xpxl1::Int32 = xend;  						#  this will be used in the main loop
	# in original algorithm, ypxl1 was integer part of yend!!!
	ypxl1::Int32 = floor(yend);
	#colorAlpha = SDL_Color(colR, colG, colB, lrint(255 * (rfpart(yend) * xgap)))				
	colorAlpha = [colR, colG, colB, lrint(255 * (rfpart(yend) * xgap))]
	if(vertical)
		#putPixel(ypxl1,xpxl1,colorAlpha,alpha);
		#pixelRGBA(win.renderer, convert(Int64, ypxl1), convert(Int64, xpxl1), r, g, b, a)
		pixelColor(win.renderer, convert(Int64, xpxl1), convert(Int64, ypxl1), colorAlpha)
		#colorAlpha=SDL_MapRGBA(alpha->format,r,g,b,255*(fpart(yend) * xgap));
		#colorAlpha[4] = 255*(fpart(yend) * xgap)
		#colorAlpha = SDL_Color(colR, colG, colB, lrint(255*(fpart(yend) * xgap)))		
		colorAlpha = [colR, colG, colB, lrint(255*(fpart(yend) * xgap))]		
		#putPixel(ypxl1 + 1, xpxl1, colorAlpha,alpha);
		#pixelRGBA(win.renderer, convert(Int64, ypxl1+1), convert(Int64, xpxl1), r, g, b, a)
		pixelColor(win.renderer, convert(Int64, xpxl1+1), convert(Int64, ypxl1), colorAlpha)
	else
		#putPixel(xpxl1, ypxl1,colorAlpha,alpha);
		#pixelRGBA(win.renderer, convert(Int64, xpxl1), convert(Int64, ypxl1), r, g, b, a)
		pixelColor(win.renderer, convert(Int64, xpxl1), convert(Int64, ypxl1), colorAlpha)
		#colorAlpha=SDL_MapRGBA(alpha->format,r,g,b,255*(fpart(yend) * xgap));
		#colorAlpha[4] = 255*(fpart(yend) * xgap)
		#colorAlpha = SDL_Color(colR, colG, colB, lrint(255*(fpart(yend) * xgap))	)			
		colorAlpha = [colR, colG, colB, lrint(255*(fpart(yend) * xgap))]		
		#putPixel(xpxl1, ypxl1 + 1, colorAlpha,alpha);
		#pixelRGBA(win.renderer, convert(Int64, xpxl1), convert(Int64, ypxl1+1), r, g, b, a)
		#    <<<<<<<<<<<<<<<<<<<<,  I think in here we can add the width.  For horizontal-based lines, ypxl1+1 is the pixel
		#    <<<<<<<<<<<<<<<<<<<<	we are merging into. We can insert a solid color here.
		pixelColor(win.renderer, convert(Int64, xpxl1), convert(Int64, ypxl1+1), colorAlpha)
		
	end
	# putPixel(xpxl1, ypxl1,colorAlpha,alpha);
	intery::Float64 = yend + gradient; 							#  first y-intersection for the main loop
	#  handle second endpoint
	xend = round(x2);
	yend = y2 + gradient * (xend - x2);
	xgap = fpart(x2 + 0.5);
	xpxl2::Int32 = xend;  #  this will be used in the main loop
	ypxl2::Int32 = floor(yend);
	# calculate color of pixel based in its distant from logical line.
	#colorAlpha[4] = 255*(rfpart(yend) * xgap);
	#colorAlpha = SDL_Color(colR, colG, colB, lrint(255*(rfpart(yend) * xgap)))
	colorAlpha = [colR, colG, colB, lrint(255*(rfpart(yend) * xgap))]		
	# following if, elses are for handling vertical and horizental lines:
	if(vertical)
		# first pixel
		#putPixel(ypxl2, xpxl2, colorAlpha,alpha);
		#pixelRGBA(win.renderer, convert(Int64, ypxl2), convert(Int64, xpxl2), r, g, b, a)
		pixelColor(win.renderer, convert(Int64, ypxl2), convert(Int64, xpxl2), colorAlpha)
		# calculate color of pixel based in its distant from logical line.
		#colorAlpha[4] = 255*(fpart(yend) * xgap)
		#colorAlpha = SDL_Color(colR, colG, colB, lrint(255*(fpart(yend) * xgap)))
		colorAlpha = [colR, colG, colB, lrint(255*(fpart(yend) * xgap))]	
		# second pixel
		#putPixel(ypxl2 + 1,xpxl2, colorAlpha,alpha);
		#pixelRGBA(win.renderer, convert(Int64, ypxl2+1), convert(Int64, xpxl2), r, g, b, a)
		pixelColor(win.renderer, convert(Int64, ypxl2+1), convert(Int64, xpxl2), colorAlpha)
	else # same as if.
		#putPixel(xpxl2, ypxl2, colorAlpha,alpha);
		#pixelRGBA(win.renderer, convert(Int64, xpxl2), convert(Int64, ypxl2), r, g, b, a)
		pixelColor(win.renderer, convert(Int64, xpxl2), convert(Int64, ypxl2), colorAlpha)
		#colorAlpha[4] = 255*(fpart(yend) * xgap);
		#colorAlpha = SDL_Color(colR, colG, colB, lrint(255*(fpart(yend) * xgap)))
		colorAlpha = [colR, colG, colB, lrint(255*(fpart(yend) * xgap))]	
	
		#putPixel(xpxl2, ypxl2 + 1, colorAlpha,alpha);
		#pixelColorWeight(win.renderer, convert(Int64, xpxl2), convert(Int64, ypxl2+1), color, colorAlpha)
		pixelColor(win.renderer, convert(Int64, xpxl2), convert(Int64, ypxl2+1), colorAlpha)
	end
	#  main loop. this is where we draw the rest of the line. like end points
	# we need to draw 2 pixel. and their alpha is calculaed from their distance
	#				 ^^^ - this could be 2, 3, 8, 20, whatever.  The in-between are solid
	# fillers.  For first pass, I would simply add filler, but that will offset the line
	# Final version should center the line, so that instead of intery, we have intery-1, intery-4, etc.
	# from logical line.
	#for (int i=xpxl1+1;i<=xpxl2-1;i++)
	for i in xpxl1+1:1:xpxl2
			#colorAlpha[4] = 255*(rfpart(intery));
			#colorAlpha = SDL_Color(colR, colG, colB, lrint(255*(rfpart(intery))))
			colorAlpha = [colR, colG, colB, lrint(255*(rfpart(intery)))]	
			if(vertical)
					#putPixel(floor(intery),i, colorAlpha,alpha);
					pixelColor(win.renderer, convert(Int64, floor(intery)), convert(Int64, i), colorAlpha)
					#colorAlpha[4] = 255*( fpart(intery));
					#colorAlpha = SDL_Color(colR, colG, colB, lrint(255*(fpart(intery))))
					colorAlpha = [colR, colG, colB, lrint(255*(fpart(intery)))]	
					#putPixel(floor(intery) + 1,i,  colorAlpha,alpha);
					pixelColor(win.renderer, convert(Int64, floor(intery+1)), convert(Int64, i), colorAlpha)
			else
					#putPixel(i,floor(intery), colorAlpha,alpha);
					pixelColor(win.renderer, convert(Int64, i), convert(Int64, floor(intery)), colorAlpha)
					#colorAlpha[4] = 255*( fpart(intery))
					#colorAlpha = SDL_Color(colR, colG, colB, lrint(255*(fpart(intery))))
					colorAlpha = [colR, colG, colB, lrint(255*(fpart(intery)))]	
					#putPixel(i, floor(intery) + 1, colorAlpha,alpha);
					pixelColor(win.renderer, convert(Int64, i), convert(Int64, floor(intery+1)), colorAlpha)
			end
			intery = intery + gradient;
		end# end for now we need to blit alpha surface to original one
#	SDL_BlitSurface(alpha,0,screen,0);
#	SDL_FreeSurface(alpha);
end
#-..........................................................................................
# This clarified how to make the lines variable width https://github.com/jambolo/thick-xiaolin-wu/blob/master/cs/thick-xiaolin-wu.coffee
function WULinesAlphaWidth(win::Window, x1::Float64, y1::Float64, x2::Float64, y2::Float64, colR::UInt8, colG::UInt8, colB::UInt8, colAlpha::UInt8,width::Int64)
	vertical::Bool =false;
	r::UInt8 = 0
	g::UInt8 = 0
	b::UInt8 = 0

	# for odd widths, we will start at -(w-1)/2.  So a width of 3 starts at -1, width of 5 starts at -2, etc.
	# for even widths, we will start at -(w-2)/2. So a width of 2 starts at 0, a width of 4 starts at -1, etc.
	# If we were really cool, we would center Even lines by somehow antialiasing the sides (cut alpha in half?)
	# in order to make the lines look centered at the start point instead of offset like we do here.

	if width%2 == 0			# even
		start = -(width-2)÷2			# integer division returns turncated int (like C)
	else
		start = -(width-1)÷2				# integer division returns turncated int (like C)
	end
	originalColor::Vector{UInt8} = [	colR, colG, colB, colAlpha]
	#colorAlpha = SDL_Color(colR, colG, colB, colAlpha)		
	colorAlpha::Vector{UInt8} = [	colR, colG, colB, colAlpha]
	# checking if this is a vertical or horizental line type.
	if(abs(y2-y1)>abs(x2-x1))
		vertical=true;
	end
	# make vertical lines horizental.
	if (vertical)
		temp = x1
		x1 = y1
		y1 = temp
		temp = x2
		x2 = y2
		y2 = temp
	end
	# if x is decreasing swap x1 and x2;
	if (x2 < x1)
		temp = x1
		x1 = x2
		x2 = temp	
		temp = y1
		y1 = y2
		y2 = temp
	end
	# line WIDTH and HEIGHT!!!
	dx::Int32 = lrint(x2 - x1);
	dy::Int32  = lrint(y2 - y1);
	# this is for calculating y from x ;)
	gradient::Float64 = (dy) / (dx);
	#  handle first endpoint. endpoints will be handle seperately. cuz they are thricky.
	#  wu's line algorithm can draw lines with non integer start and end. so we need to
	# have an integer to start with.
	xend::Int32 = round(x1);
	# some good y for end point this is also an int.
	yend::Float64 = y1 + gradient * (xend - x1);
	# xgap is simply pixel around integer
	xgap::Float64 = rfpart(x1 + 0.5);
	xpxl1::Int32 = xend;  						#  this will be used in the main loop
	# in original algorithm, ypxl1 was integer part of yend!!!
	ypxl1::Int32 = floor(yend);
	#colorAlpha = SDL_Color(colR, colG, colB, lrint(255 * (rfpart(yend) * xgap)))				
	colorAlpha = [colR, colG, colB, lrint(255 * (rfpart(yend) * xgap))]
	if(vertical)
		pixelColor(win.renderer, convert(Int64, xpxl1), convert(Int64, ypxl1), colorAlpha)
		colorAlpha = [colR, colG, colB, lrint(255*(fpart(yend) * xgap))]		
		pixelColor(win.renderer, convert(Int64, xpxl1+1), convert(Int64, ypxl1), colorAlpha)
	else
		pixelColor(win.renderer, convert(Int64, xpxl1), convert(Int64, ypxl1), colorAlpha)
		colorAlpha = [colR, colG, colB, lrint(255*(fpart(yend) * xgap))]		
		#putPixel(xpxl1, ypxl1 + 1, colorAlpha,alpha);
		#pixelRGBA(win.renderer, convert(Int64, xpxl1), convert(Int64, ypxl1+1), r, g, b, a)
		pixelColor(win.renderer, convert(Int64, xpxl1), convert(Int64, ypxl1+1), colorAlpha)
		
	end
	# putPixel(xpxl1, ypxl1,colorAlpha,alpha);
	intery::Float64 = yend + gradient; 							#  first y-intersection for the main loop
	#  handle second endpoint
	xend = round(x2);
	yend = y2 + gradient * (xend - x2);
	xgap = fpart(x2 + 0.5);
	xpxl2::Int32 = xend;  #  this will be used in the main loop
	ypxl2::Int32 = floor(yend);
	# calculate color of pixel based in its distant from logical line.
	#colorAlpha[4] = 255*(rfpart(yend) * xgap);
	#colorAlpha = SDL_Color(colR, colG, colB, lrint(255*(rfpart(yend) * xgap)))
	colorAlpha = [colR, colG, colB, lrint(255*(rfpart(yend) * xgap))]		
	# following if, elses are for handling vertical and horizental lines:
	if(vertical)
		# first pixel
		pixelColor(win.renderer, convert(Int64, ypxl2), convert(Int64, xpxl2), colorAlpha)
		# calculate color of pixel based in its distant from logical line.
		colorAlpha = [colR, colG, colB, lrint(255*(fpart(yend) * xgap))]	
		# second pixel
		pixelColor(win.renderer, convert(Int64, ypxl2+1), convert(Int64, xpxl2), colorAlpha)
	else # same as if.
		pixelColor(win.renderer, convert(Int64, xpxl2), convert(Int64, ypxl2), colorAlpha)
		colorAlpha = [colR, colG, colB, lrint(255*(fpart(yend) * xgap))]	
		pixelColor(win.renderer, convert(Int64, xpxl2), convert(Int64, ypxl2+1), colorAlpha)
	end
	#  main loop. this is where we draw the rest of the line. like end points
	# we need to draw 2 pixel. and their alpha is calculaed from their distance
	#				 ^^^ - this could be 2, 3, 8, 20, whatever.  The in-between are solid
	# fillers.  For first pass, I would simply add filler, but that will offset the line
	# Final version should center the line, so that instead of intery, we have intery-1, intery-4, etc.
	# from logical line.
	#for (int i=xpxl1+1;i<=xpxl2-1;i++)
	for i in xpxl1+1:1:xpxl2
			colorAlpha = [colR, colG, colB, lrint(255*(rfpart(intery)))]	
			if(vertical)
					# pixelColor( renderer, x, y, color)
					pixelColor(win.renderer, convert(Int64, floor(intery+start)), convert(Int64, i), colorAlpha)
					#This is how we add the width.  Only sides are antialiased.
					for w in 1:(width-1)
						pixelColor(win.renderer, convert(Int64, floor(intery+start+w)), convert(Int64, i), originalColor)
					end
					colorAlpha = [colR, colG, colB, lrint(255*(fpart(intery)))]	
					pixelColor(win.renderer, convert(Int64, floor(intery+start+width)), convert(Int64, i), colorAlpha)
			else
					pixelColor(win.renderer, convert(Int64, i), convert(Int64, floor(intery+start)), colorAlpha)			# x, intery    , rfpart
					for w in 1:(width-1)
						pixelColor(win.renderer, convert(Int64, i), convert(Int64, floor(intery+start+w)), originalColor)
					end
					colorAlpha = [colR, colG, colB, lrint(255*(fpart(intery)))]	
					pixelColor(win.renderer, convert(Int64, i), convert(Int64, floor(intery+start+width)), colorAlpha)		# x, intery + w,  fpart
			end
			intery = intery + gradient;
		end# end for now we need to blit alpha surface to original one
end

#pixelColorWeight


#=

  # main loop
  if steep
    for x in [xpxl1 + 1...xpxl2]
      fpart = intery - Math.floor(intery)
      rfpart = 1 - fpart
      y = Math.floor(intery)
      drawPixel y    , x, rfpart
      drawPixel y + i, x,      1 for i in [1...w]
      drawPixel y + w, x,  fpart
      intery = intery + gradient
  else
    for x in [xpxl1 + 1...xpxl2]
      fpart = intery - Math.floor(intery)
      rfpart = 1 - fpart
      y = Math.floor(intery)
      drawPixel x, y    , rfpart
      drawPixel x, y + i,      1 for i in [1...w]
      drawPixel x, y + w,  fpart
      intery = intery + gradient
  return

=#
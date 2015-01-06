// C++98 code
#include <mex.h>
#include "mexutils.h"
#include "cppmatrix.h" 
#include <iostream>
#include <memory>
#include <algorithm>

#include <GridGraph_2D_4C.h>
//#include <GridGraph_2D_4C_MT.h>
#include <GridGraph_2D_8C.h>

#include <GridGraph_3D_6C.h>
//#include <GridGraph_3D_6C_MT.h>
#include <GridGraph_3D_26C.h>

using std::max;
using std::min;

class ValidIndex {
public:
	ValidIndex(const size_t dims[3]) : dims(dims) 
	{}

	bool operator()(size_t x, size_t y) { 
		if (x < 0) return false;
		if (x >= dims[0]) return false;
		if (y < 0) return false;
		if (y >= dims[1]) return false;

		return true; 
	}

	bool operator()(size_t x, size_t y, size_t z) { 
		if (x < 0) return false;
		if (x >= dims[0]) return false;
		if (y < 0) return false;
		if (y >= dims[1]) return false;
		if (z < 0)  return false;
		if (z >= dims[2]) return false;

		return true;
	}

private:
	const size_t* dims;
};

template<typename Real>
class Regularization {
public:
	Regularization(Real strength) : strength(strength)
	{}

	Real operator() (Real weight) {   
		return strength*weight;
	}

private:
	const Real strength;
};


///
/// 2D 
///
template<typename Real, typename Grid>
void segment_2D(int nlhs, mxArray  *plhs[], int nrhs, const mxArray  *prhs[])
{
	const matrix<Real> data_term(prhs[0]);
	const matrix<int> conn_list(prhs[1]);
	const matrix<double> conn_weights(prhs[2]);

	MexParams params(1, prhs+(nrhs-1));
	Real regularization_strength = static_cast<Real>(params.get<double>("regularization_strength",0.0));
	size_t dims[3] = {data_term.M, data_term.N, data_term.O};
	ValidIndex validIndex(dims);
	Regularization<Real> regularization(regularization_strength);

	// Change to unique_ptr in C++11.
	std::auto_ptr<Grid> grid(new Grid(dims[0],dims[1]));

	for (size_t j = 0; j < dims[1]; ++j) {
	for (size_t i = 0; i < dims[0]; ++i) {
		
	// Data term
	 grid->set_terminal_cap(
		grid->node_id(i,j),
			max(data_term(i,j), Real(0)),
			max(-data_term(i,j), Real(0))
	 );

		// Regularization term
		for (size_t ind=0; ind < conn_list.N; ++ind) {

			if (validIndex(
				i + conn_list(0,ind),
				j + conn_list(1,ind))
				 )
			{
				grid->set_neighbor_cap(
						grid->node_id(i,j),  
						conn_list(0,ind) ,
						conn_list(1,ind),
						regularization(conn_weights(ind))
						);
			} 
		}
			
	}}

	// Solve
	grid->compute_maxflow();

	// Extract solution
	matrix<bool> segmentation(dims[0],dims[1]);
	for (size_t j = 0; j < dims[1]; ++j ) {
	for (size_t i = 0; i < dims[0]; ++i) {
		segmentation(i,j) = grid->get_segment(grid->node_id(i,j)) == 1;
	}
	}

	plhs[0] = segmentation;
}

//
// 3D
//
template<typename Real, typename Grid>
void segment_3D(int nlhs, mxArray  *plhs[], int nrhs, const mxArray  *prhs[])
{
	
	const matrix<Real> data_term(prhs[0]);
	const matrix<int> conn_list(prhs[1]);
	const matrix<double> conn_weights(prhs[2]);

	MexParams params(1, prhs+(nrhs-1));
	Real regularization_strength = static_cast<Real>(params.get<double>("regularization_strength",0.0));
	size_t dims[3] = {data_term.M, data_term.N, data_term.O};
	ValidIndex validIndex(dims);
	Regularization<Real> regularization(regularization_strength);


	// Change to unique_ptr in C++11.
	std::auto_ptr<Grid> grid(new Grid(dims[0],dims[1], dims[2]));


	for (size_t l = 0; l < dims[2]; ++l) {
	for (size_t j = 0; j < dims[1]; ++j) {
	for (size_t i = 0; i < dims[0]; ++i) {

	// Data term
	 grid->set_terminal_cap(
		grid->node_id(i,j,l),
			max(data_term(i,j,l), Real(0)),
			max(-data_term(i,j,l), Real(0))
	 );

		// Regularization term
		for (size_t ind=0; ind < conn_list.N; ++ind) {

			if (validIndex(
				i + conn_list(0,ind),
				j + conn_list(1,ind),
				l + conn_list(2,ind))
			)
			{
				grid->set_neighbor_cap(
						grid->node_id(i,j,l),  
						conn_list(0,ind),
						conn_list(1,ind),
						conn_list(2,ind),
						regularization(conn_weights(ind))
						);
			} 
		}
			
	}}}

	// Solve
	grid->compute_maxflow();

	// Extract solution
	matrix<bool> segmentation(dims[0],dims[1], dims[2]);

	for (size_t l = 0; l < dims[2]; ++l) {
	for (size_t j = 0; j < dims[1]; ++j) {
	for (size_t i = 0; i < dims[0]; ++i) {
		segmentation(i,j,l) = grid->get_segment(grid->node_id(i,j,l)) == 1;
	}
	}
	}

	plhs[0] = segmentation;
}

void mexFunction(int            nlhs,     /* number of expected outputs */
								 mxArray        *plhs[],  /* mxArray output pointer array */
								 int            nrhs,     /* number of inputs */
								 const mxArray  *prhs[]   /* mxArray input pointer array */)
{
	const mxArray * data_term_ptr = prhs[0];

	MexParams params(1, prhs+(nrhs-1));
	int connectivity = params.get<int>("connectivity");

	if (mxGetClassID(data_term_ptr) == mxDOUBLE_CLASS) {
		typedef double Real;

		switch(connectivity) {
			case 4:
					segment_2D<Real, GridGraph_2D_4C<Real, Real, Real> >(nlhs, plhs, nrhs, prhs);
					break;

			case 8:
					segment_2D<Real, GridGraph_2D_8C<Real, Real, Real> >(nlhs, plhs, nrhs, prhs);
					break;

			case 6:
					segment_3D<Real, GridGraph_3D_6C<Real, Real, Real> >(nlhs, plhs, nrhs, prhs);
					break;

			case 26:
					segment_3D<Real, GridGraph_3D_26C<Real, Real, Real> >(nlhs, plhs, nrhs, prhs);
					break;
		}
	} else if (mxGetClassID(data_term_ptr) == mxSINGLE_CLASS) {
		typedef float Real;

		switch(connectivity) {
			case 4:
					segment_2D<Real, GridGraph_2D_4C<Real, Real, Real> >(nlhs, plhs, nrhs, prhs);
					break;

			case 8:
					segment_2D<Real, GridGraph_2D_8C<Real, Real, Real> >(nlhs, plhs, nrhs, prhs);
					break;

			case 6:
					segment_3D<Real, GridGraph_3D_6C<Real, Real, Real> >(nlhs, plhs, nrhs, prhs);
					break;

			case 26:
					segment_3D<Real, GridGraph_3D_26C<Real, Real, Real> >(nlhs, plhs, nrhs, prhs);
					break;
		}
	} 
}
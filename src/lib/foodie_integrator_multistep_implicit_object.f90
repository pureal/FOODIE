!< Define the abstract type [[integrator_multistep_implicit_object]] of FOODIE ODE integrators.

module foodie_integrator_multistep_implicit_object
!< Define the abstract type [[integrator_multistep_implicit_object]] of FOODIE ODE integrators.

use, intrinsic :: iso_fortran_env, only : stderr=>error_unit
use foodie_integrand_object, only : integrand_object
use foodie_integrator_object, only : integrator_object
use penf, only : I_P, R_P

implicit none
private
public :: integrator_multistep_implicit_object

type, extends(integrator_object), abstract :: integrator_multistep_implicit_object
   !< Abstract type of FOODIE ODE integrators of the multistep-implicit family.
   integer(I_P) :: steps=-1 !< Number of time steps.
   contains
      ! deferred methods
      procedure(integrate_interface),      pass(self), deferred :: integrate      !< Integrate integrand field.
      procedure(integrate_fast_interface), pass(self), deferred :: integrate_fast !< Integrate integrand field, fast mode.
      ! implemented deferred methods of parent
      procedure, pass(self) :: is_multistage !< Return .true. for multistage integrator.
      procedure, pass(self) :: is_multistep  !< Return .true. for multistep integrator.
      procedure, pass(self) :: stages_number !< Return number of stages used.
      procedure, pass(self) :: steps_number  !< Return number of steps used.
      ! public methods
      procedure, pass(self) :: destroy_multistep !< Destroy the integrator.
      procedure, pass(self) :: update_previous   !< Cyclic update previous time steps.
endtype integrator_multistep_implicit_object

abstract interface
   !< Abstract interfaces of deferred methods of [[integrator_multistep_implicit_object]].
   subroutine integrate_interface(self, U, previous, Dt, t, iterations, autoupdate)
   !< Integrate integrand field.
   import :: integrand_object, integrator_multistep_implicit_object, I_P, R_P
   class(integrator_multistep_implicit_object), intent(in)    :: self         !< Integrator.
   class(integrand_object),                     intent(inout) :: U            !< Integrand.
   class(integrand_object),                     intent(inout) :: previous(1:) !< Previous time steps solutions of integrand field.
   real(R_P),                                   intent(in)    :: Dt           !< Time steps.
   real(R_P),                                   intent(in)    :: t(:)         !< Times.
   integer(I_P), optional,                      intent(in)    :: iterations   !< Fixed point iterations.
   logical,      optional,                      intent(in)    :: autoupdate   !< Perform cyclic autoupdate of previous time steps.
   endsubroutine integrate_interface

   subroutine integrate_fast_interface(self, U, previous, buffer, Dt, t, iterations, autoupdate)
   !< Integrate integrand field, fast mode.
   import :: integrand_object, integrator_multistep_implicit_object, I_P, R_P
   class(integrator_multistep_implicit_object), intent(in)    :: self         !< Integrator.
   class(integrand_object),                     intent(inout) :: U            !< Field to be integrated.
   class(integrand_object),                     intent(inout) :: previous(1:) !< Previous time steps solutions of integrand field.
   class(integrand_object),                     intent(inout) :: buffer       !< Temporary buffer for doing fast operation.
   real(R_P),                                   intent(in)    :: Dt           !< Time steps.
   real(R_P),                                   intent(in)    :: t(:)         !< Times.
   integer(I_P), optional,                      intent(in)    :: iterations   !< Fixed point iterations.
   logical, optional,                           intent(in)    :: autoupdate   !< Perform cyclic autoupdate of previous time steps.
   endsubroutine integrate_fast_interface
endinterface

contains
   ! deferred methods
   elemental function is_multistage(self)
   !< Return .true. for multistage integrator.
   class(integrator_multistep_implicit_object), intent(in) :: self          !< Integrator.
   logical                                                 :: is_multistage !< Inquire result.

   is_multistage = .false.
   endfunction is_multistage

   elemental function is_multistep(self)
   !< Return .true. for multistage integrator.
   class(integrator_multistep_implicit_object), intent(in) :: self         !< Integrator.
   logical                                                 :: is_multistep !< Inquire result.

   is_multistep = .true.
   endfunction is_multistep

   elemental function stages_number(self)
   !< Return number of stages used.
   class(integrator_multistep_implicit_object), intent(in) :: self          !< Integrator.
   integer(I_P)                                            :: stages_number !< Number of stages used.

   stages_number = 0
   endfunction stages_number

   elemental function steps_number(self)
   !< Return number of steps used.
   class(integrator_multistep_implicit_object), intent(in) :: self         !< Integrator.
   integer(I_P)                                            :: steps_number !< Number of steps used.

   steps_number = self%steps
   endfunction steps_number

   ! public methods
   elemental subroutine destroy_multistep(self)
   !< Destroy the integrator.
   class(integrator_multistep_implicit_object), intent(inout) :: self !< Integrator.

   call self%destroy_abstract
   self%steps = -1
   endsubroutine destroy_multistep

   subroutine update_previous(self, U, previous, is_like_explicit)
   !< Cyclic update previous time steps.
   class(integrator_multistep_implicit_object), intent(in)    :: self              !< Integrator.
   class(integrand_object),                     intent(in)    :: U                 !< Field to be integrated.
   class(integrand_object),                     intent(inout) :: previous(1:)      !< Previous time steps solutions of integrand.
   logical, optional,                           intent(in)    :: is_like_explicit  !< Use explicit-like update.
   logical                                                    :: is_like_explicit_ !< Use explicit-like update, local variable.
   integer(I_P)                                               :: s                 !< Steps counter.

   is_like_explicit_ = .false. ; if (present(is_like_explicit)) is_like_explicit_ = is_like_explicit
   if (is_like_explicit_) then
      do s=1, self%steps - 1
        previous(s) = previous(s + 1)
      enddo
      previous(self%steps) = U
   else
      if (self%steps > 0) then
        do s=0, self%steps - 2
          previous(s + 1) = previous(s + 2)
        enddo
        previous(self%steps) = U
      endif
   endif
   endsubroutine update_previous
endmodule foodie_integrator_multistep_implicit_object

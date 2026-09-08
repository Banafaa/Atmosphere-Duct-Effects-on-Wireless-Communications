# [WP#005] Same Atmospheric Duct, Different Frequencies
## What Actually Happens to the Electromagnetic Field?

**Wireless Propagation (WP)**

---

## Overview

In [WP#004], we explored how the ability of an atmospheric duct to
confine radio waves depends on operating frequency, duct thickness,
and duct strength.

But satisfying the approximate trapping condition does not tell us
what the electromagnetic field actually looks like after the wave
enters the duct.

Once trapped, electromagnetic waves interact continuously with the
vertical refractivity structure and the lower boundary. Their
superposition produces a spatially varying field containing regions
of constructive and destructive interference.

As a result, two frequencies propagating through the **same atmospheric
duct** can produce fundamentally different spatial field distributions.

WP#005 moves from the approximate trapping criterion introduced in
WP#004 to a numerical electromagnetic propagation model using the
**Parabolic Equation (PE) method**.

---

## From Trapping Condition to Electromagnetic Field

WP#004 addressed the question:

> **Can a given duct support significant confinement at this frequency?**

WP#005 addresses a different question:

> **Once the wave is confined, how does the electromagnetic field evolve
> with range and altitude?**

The distinction is important.

A signal being trapped does not imply that its field strength remains
constant throughout the duct.

Instead, the electromagnetic field develops a complex spatial structure
that depends strongly on operating frequency.

---

## Parabolic Equation Method

Atmospheric duct propagation can be modeled using the
**Parabolic Equation (PE)** approximation to the electromagnetic
wave equation.

For a two-dimensional propagation environment, the field is represented
as:

\[
E(x,z)
\]

where:

- **x** = propagation range
- **z** = altitude
- **E(x,z)** = complex electromagnetic field

The PE method numerically propagates the field through the atmospheric
refractivity environment while accounting for the vertical structure
of the atmosphere.

Unlike a simple ray representation, the resulting solution describes
the continuous electromagnetic field over both **range and altitude**.

This makes it possible to observe interference patterns, field maxima,
field minima, and frequency-dependent spatial structures inside the duct.

---

## Why Frequency Changes the Field Pattern

Changing the operating frequency changes the wavelength:

\[
\lambda = \frac{c}{f}
\]

Therefore, even when the atmospheric duct remains unchanged, changing
frequency modifies the phase evolution and interference structure of
the propagating field.

The resulting field may contain:

- **Constructive-interference regions** — local field maxima or peaks
- **Destructive-interference regions** — local field minima or nulls
- **Different vertical field structures**
- **Different range-dependent fading patterns**

Consequently:

> **Higher frequency does not simply mean better propagation.**

Different frequencies can produce entirely different electromagnetic
field distributions inside the same atmospheric duct.

---

## Simulation Scenario

To isolate the effect of operating frequency, the simulation keeps the
atmospheric environment and propagation geometry fixed while changing
only the carrier frequency.

Three frequencies are compared:

| Frequency | Comparison |
|---:|---|
| **1 GHz** | Lower-frequency case |
| **5 GHz** | Intermediate-frequency case |
| **10 GHz** | Higher-frequency case |

The same duct geometry and antenna configuration are applied to all
three simulations.

This allows differences in the resulting field patterns to be attributed
primarily to the change in operating wavelength.

---

## Visualization

![PE frequency comparison](Figures/WP005_figure01.gif)

The animation presents two complementary views of each PE simulation.

### 2D Field Distribution

The right-hand panels show the electromagnetic field as a function of:

- Propagation range
- Altitude

These maps reveal the spatial complexity of the field inside the
atmospheric duct.

### Receiver-Height Field

The left-hand panel extracts the field along a fixed receiver altitude.

This provides a direct view of how received field strength varies with
range for each operating frequency.

Together, these views demonstrate that two signals can both experience
ducted propagation while producing very different field strengths at a
particular receiver location.

---

## Practical Implication

Consider a receiver located approximately **40 km** from the transmitter
at an altitude of **30 m**.

Depending on the spatial field pattern, one operating frequency may place
the receiver near a constructive-interference region while another may
place the same receiver near a destructive-interference null.

Therefore, the same atmospheric duct can produce:

- Strong signal enhancement at one frequency
- Significant fading at another frequency

even though both signals are propagating within the same atmospheric
environment.

This is an important distinction for practical communication and radar
systems:

> **Ducted propagation does not imply uniformly enhanced signal strength.**

The actual received field depends on the spatial electromagnetic field
distribution at the receiver location.

---

## MATLAB Simulation

The MATLAB implementation used to generate the PE visualization is
provided in:

`WP005_PE_Frequency_Comparison.m`

The simulation:

1. Defines a common atmospheric duct profile.
2. Fixes the transmitter and receiver geometry.
3. Defines the operating frequencies of 1, 5, and 10 GHz.
4. Computes the electromagnetic field using the Parabolic Equation method.
5. Generates the two-dimensional field distribution over range and altitude.
6. Extracts the field along the selected receiver altitude.
7. Compares the resulting frequency-dependent field structures.
8. Exports the visualization as an animated GIF.

Unlike the conceptual ray visualization used in WP#004, WP#005 evaluates
the spatial electromagnetic field numerically using the PE framework.

---

## LinkedIn Post

### [WP#005] Same Atmospheric Duct, Different Frequencies:
### What Actually Happens to the Electromagnetic Field?

In **WP#004**, we saw that an atmospheric duct exhibits frequency-selective
trapping behavior: whether a signal is effectively confined depends on
the relationship between its wavelength and the duct characteristics.

But once a signal is successfully trapped, what does the actual
electromagnetic field look like inside this invisible waveguide?

It is a common misconception that a higher frequency simply "propagates
better." In reality, changing the operating frequency fundamentally alters
the spatial structure of the field.

As trapped waves propagate within the duct, their different phase
components interact. Different wavelengths therefore create different
spatial structures, including regions of constructive interference
(**peaks**) and destructive interference (**nulls**).

To simulate these interactions over long propagation distances, engineers
can use the **Parabolic Equation (PE) method**. By computing the
forward-propagating field, the PE captures two-dimensional spatial
variations that cannot be represented by simple ray trajectories alone.

### The Practical Impact

This spatial behavior means that signal strength can be highly localized.

A receiver situated **40 km** away at an altitude of **30 m** might
experience strong signal enhancement at 5 GHz while lying near a deep
field null at 10 GHz, despite both signals propagating through the same
atmospheric duct.

### The Figure

The animation demonstrates this phenomenon using PE simulations.

The duct and antenna geometry are held fixed while **1, 5, and 10 GHz**
are simulated for comparison.

The right-hand panels map the two-dimensional electromagnetic field over
range and altitude, while the left-hand panel tracks the corresponding
field variation along the receiver altitude.

**Next up:** Ducted does not mean constant. We will explore why a deeply
confined signal can still experience substantial fading and oscillations
across a long-range link.

---

## References

1. M. Levy, *Parabolic Equation Methods for Electromagnetic Wave
   Propagation*, IEE Electromagnetic Waves Series 45, 2000.

2. M. Banafaa and A. H. Muqaibel,
   "Tropospheric Ducting: A Comprehensive Review and Machine
   Learning-Based Classification Advancements,"
   *IEEE Access*, vol. 13, 2025.  
   DOI: 10.1109/ACCESS.2025.3537160

---

## Author

**Mohammed Banafaa**

Wireless Propagation (WP)  
\
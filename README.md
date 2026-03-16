## Purpose
Traditional monitoring devices are hindered by high latency and battery drain due to continuous data transmission and redundant digital processing. This project addresses these limitations by developing an unsupervised Spiking Neural Network (SNN) on a DE10-Lite FPGA for real-time ECG arrhythmia detection. Leveraging the parallelism of neuromorphic hardware and the event-driven nature of SNNs, to achieve extreme energy efficiency and low-latency edge AI.

## Math
Leaky Integrate-and-Fire (LIF)

*The core of each neuron is modeled using the LIF differential equation:*
<p align="center">
  <img src="Assets/Screenshot%202026-03-15%20184909.png" width="300">
</p>

*In hardware, this is discretized for the FPGA implementation as:*

<p align="center">
  <img src="Assets/Screenshot%202026-03-15%20191622.png" width="400">
</p>

*To enable unsupervised learning, Spike-Timing-Dependent Plasticity(STDP) is used, synaptic weights are updated based on the relative timing of spikes:*

<p align="center">
  <img src="Assets/Screenshot%202026-03-15%20190442.png" width="400">
</p>


<p align="center">
  <img src="Assets/Screenshot%202026-03-15%20191301.png" width="400">
</p>

To make this more like the human brain, I used lateral inhibition to prevent multiple neurons from firing simultaneously and a fatigue mechanism (refractory period) to regulate firing rates and ensure diverse feature detection.

## Rough Block Diagram

<p align="center">
  <img src="Assets/Screenshot%202026-03-15%20193902.png" width="600">
</p>

## Input Data for Simulation
I used the MIT-BIH Arrhythmia Database for simulation and testing, which contains 48 half-hour excerpts of two-channel ambulatory ECG recordings, obtained from 47 subjects.
(Goldberger, A., et al. "PhysioBank, PhysioToolkit, and PhysioNet: Components of a new research resource for complex physiologic signals. Circulation [Online]. 101 (23), pp. e215–e220." (2000). RRID:SCR_007345.)

*Here is a vizualization of the data:*
<p align="center">
  <img src="Assets/Screenshot%202026-03-15%20194228.png" width="600">
</p>

## RTL Block Schematics
This is the top-level view of the synthesized hardware:
<p align="center">
  <img src="Assets/Screenshot%202026-03-15%20195303.png" width="700">
</p>

This is the RTL schematic of the spike encoder module:
<p align="center">
  <img src="Assets/Screenshot%202026-03-15%20195338.png" width="800">
</p>

This is the RTL schematic of the individual neurons: 

<p align="center">
  <img src="Assets/Screenshot%202026-03-15%20195847.png" width="1000">
</p>
<p align="center">
  <img src="Assets/Screenshot%202026-03-15%20195811.png" width="1200">
</p>

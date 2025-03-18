# 基于剪枝和霍夫曼编码的多核二维Systolic阵列上的卷积神经网络（CNNs）

本项目旨在探索如何在多核二维Systolic阵列架构上，通过模型剪枝和霍夫曼编码等模型压缩技术，加速卷积神经网络（CNN）的推理过程。

## 项目结构

- **Part1**：使用量化感知训练（Quantization-Aware Training）对VGG16模型进行训练。
- **Part2**：设计RTL核心，连接各功能模块。
- **Part3**：设计以权重为中心的处理单元（Weight Stationary PE）。
- **Part4**：在FPGA（Cyclone IV GX EP4CGX150DF31I7AD）上进行映射。
- **Part5**：设计可重构的处理单元，支持权重和输出的存储。
- **Part6**：集成五个附加功能的最终系统。
- **Part7**：项目海报和报告。

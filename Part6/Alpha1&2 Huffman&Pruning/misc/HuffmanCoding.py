class HuffmanNode:
    def __init__(self, val=None, freq=None, left=None, right=None):
        self.val = val
        self.freq = freq
        self.left = left
        self.right = right
        # self.code = ""
 
    def __lt__(self, other):
        return self.freq < other.freq


def huffman_encoding(counter):
    node_list = [HuffmanNode(val, freq) for val, freq in enumerate(counter)]
    while len(node_list) > 1:
        node_list.sort()
        left = node_list.pop(0)
        right = node_list.pop(0)
        newNode = HuffmanNode(None, left.freq + right.freq, left, right)
        node_list.append(newNode)

    res_dict = {}
    def _encode(node, code):
        if node == None:
            return
        if node.val != None:
            res_dict[node.val] = code
            return
        _encode(node.left, code+'0')
        _encode(node.right, code+'1')

    _encode(node_list[0], '')
    return res_dict